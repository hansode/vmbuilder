# -*-Shell-script-*-
#
# description:
#  Virtual disk management
#
# requires:
#  bash
#  truncate, rm
#  mkdir, MAKEDEV, mount, umount
#  cat, egrep, awk
#  parted, kpartx, udevadm, blkid
#  mkfs.ext4, tune2fs, mkswap
#
# imports:
#  utils: checkroot
#

## disk

function mkdisk() {
  #
  # Creates the disk image (if it doesn't already exist).
  #
  local disk_filename=$1 size=${2:-0} unit=${3:-m}
  [[ -a "${disk_filename}" ]] && { echo "already exists: ${disk_filename} (disk:${LINENO})" >&2; return 1; }
  [[ "${size}" -gt 0 ]] || { echo "[ERROR] Invalid argument: size:${size} (disk:${LINENO})" >&2; return 1; }

  truncate -s ${size}${unit} ${disk_filename}
}

## filesystem

function mkdevice() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (disk:${LINENO})" >&2; return 1; }
  checkroot || return 1

  mkdir ${chroot_dir}/dev
  local i=
  for i in console null tty1 tty2 tty3 tty4 zero; do
    MAKEDEV -d ${chroot_dir}/dev -x ${i}
  done
}

function mkprocdir() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (disk:${LINENO})" >&2; return 1; }

  mkdir ${chroot_dir}/proc
}

function mount_proc() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (disk:${LINENO})" >&2; return 1; }
  checkroot || return 1

  mount --bind /proc ${chroot_dir}/proc
}

function mount_dev() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (disk:${LINENO})" >&2; return 1; }
  checkroot || return 1

  mount --bind /dev ${chroot_dir}/dev
}

function umount_root() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (disk:${LINENO})" >&2; return 1; }
  checkroot || return 1

  printf "[DEBUG] Unmounting %s\n" ${chroot_dir}
  umount ${chroot_dir}
}

function umount_nonroot() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (disk:${LINENO})" >&2; return 1; }
  checkroot || return 1

  local mountpoint=
  while read mountpoint; do
    printf "[DEBUG] Unmounting %s\n" ${mountpoint}
    umount ${mountpoint}
  done < <(egrep ${chroot_dir}/ /etc/mtab | awk '{print $2}')
}

## ptab

function xptabinfo() {
  {
    [[ -n "${xpart}" ]] && [[ -f "${xpart}" ]] && {
      cat ${xpart}
    } || {
      cat <<-EOS
	/boot ${bootsize:-0}
	root  ${rootsize:-0}
	swap  ${swapsize:-0}
	/opt  ${optsize:-0}
	/home ${homesize:-0}
	/usr  ${usrsize:-0}
	/var  ${varsize:-0}
	EOS
    }
  } | egrep -v '^$|^#' | awk '$2 != 0 {print $1, $2}'
}

function xptabproc() {
  local blk="$(cat)"

  local mountpoint= partsize=
  while read mountpoint partsize; do
    eval "${blk}"
  done < <(xptabinfo)
}

function mkpart() {
  #
  # Adds partition to the disk image (does not mkfs or anything like that)
  #
  # fstype: should allow empty for extended parttype
  local disk_filename=$1 parttype=${2:-primary} offset=${3:-0} size=${4:-0} fstype=${5:-}
  [[ -a "${disk_filename}" ]] || { echo "file not found: ${disk_filename} (disk:${LINENO})" >&2; return 1; }
  #
  # size == -1 or size > 0. "-1" means whole disk
  #
  [ "${size}" -eq -1 -o "${size}" -gt 0 ] || { echo "[ERROR] Invalid argument: size:${size} (disk:${LINENO})" >&2; return 1; }
  checkroot || return 1

  case "${parttype}" in
  primary)
    ;;
  logical)
    ;;
  extended)
    ;;
  *)
    echo "[ERROR] Invalid parttype: ${parttype} (disk:${LINENO})" >&2
    return 1
    ;;
  esac

  case "${fstype}" in
  ext2)
    ;;
  swap)
    fstype="linux-swap(new)"
    ;;
  "")
    # for extended parttype
    ;;
  *)
    echo "[ERROR] Invalid fstype: ${fstype} (disk:${LINENO})" >&2
    return 1
    ;;
  esac

  local partition_start=${offset}
  local partition_end=$((${offset} + ${size} - 1))

  # # parted --script -- ${disk_filename} unit s print
  # Model:  (file)
  # Disk ${disk_filename} 10485760s
  # Sector size (logical/physical): 512B/512B
  # Partition Table: msdos
  # 
  # Number  Start     End        Size      Type      File system  Flags
  #  1      63s       60546s     60484s    primary                boot
  #  2      61440s    497663s    436224s   primary
  #  3      499712s   505855s    6144s     primary
  #  4      507904s   10485759s  9977856s  extended
  #  5      507967s   1255859s   747893s   logical
  #  6      1257472s  1380351s   122880s   logical
  #  7      1382400s  1388543s   6144s     logical
  #  8      1390592s  1396735s   6144s     logical
  local previous_partition=$(parted --script -- ${disk_filename} unit s print | egrep -v '^$' | awk '$1 ~ "^[1-9]+"' | tail -1)

  case "${previous_partition}" in
  "")
    # 1st primary
    case "${parttype}" in
    primary)
      ;;
    *)
      echo "[ERROR] Invalid parttype: ${parttype} (disk:${LINENO})" >&2
      return 1
      ;;
    esac
    ;;
  *extended)
    # 1st logical
    partition_start=$(echo "${previous_partition}" | awk '{print $2}' | sed 's,s$,,') ;;
  *)
    # others
    false
    ;;
  esac && {
    printf "[INFO] Partition at beginning of disk - reserving first cylinder\n"
    partition_start=$((${partition_start} + 63))s
  } || :

  # whole disk
  [[ "${size}" == -1 ]] && {
    partition_end=-1
  }

  printf "[INFO] Adding type %s partition to disk image: %s\n" ${fstype} ${disk_filename}
  parted --script -- ${disk_filename} mkpart ${parttype} ${fstype} ${partition_start} ${partition_end}
  # for physical /dev/XXX
  udevadm settle
}

function mkptab() {
  #
  # Partitions the disk image. First adds a partition table and then
  # adds the individual partitions.
  #
  # Should only be called once and only after you've added all partitions.
  #
  local disk_filename=$1
  [[ -a "${disk_filename}" ]] || { echo "file not found: ${disk_filename} (disk:${LINENO})" >&2; return 1; }

  printf "[INFO] Adding partition table to disk image: %s\n" ${disk_filename}
  parted --script ${disk_filename} mklabel msdos

  local i=1 offset=0 parttype=
  xptabproc <<'EOS'
    case "${mountpoint}" in
    swap) fstype=swap ;;
    *)    fstype=ext2 ;;
    esac

    case "${i}" in
    [1-3])
      parttype=primary
      ;;
    4)
      parttype=extended
      # don't need to set fstype about extended partition to mkpart function.
      # extended partition ses other whole disk. "-1" measn whole disk in parted command.
      mkpart ${disk_filename} ${parttype} ${offset} -1
      # disable lba flagg
      parted --script -- ${disk_filename} set ${i} lba off
      parttype=logical
      ;;
    *)
      parttype=logical
      ;;
    esac

    mkpart ${disk_filename} ${parttype} ${offset} ${partsize} ${fstype}
    offset=$((${offset} + ${partsize}))

    case "${mountpoint}" in
    /boot)
      # set boot flag
      parted --script -- ${disk_filename} set ${i} boot on
      ;;
    esac

    let i++
EOS
}

function mapptab() {
  #
  # Create loop devices corresponding to the partitions.
  #
  # Once this has returned succesfully, each partition's map device
  # is set as its L{filename<Disk.Partition.filename>} attribute.
  #
  # Call this after L{partition}.
  #
  local disk_filename=$1
  [[ -a "${disk_filename}" ]] || { echo "file not found: ${disk_filename} (disk:${LINENO})" >&2; return 1; }
  checkroot || return 1

  # # kpartx -va ${disk_filename}
  # add map loop0p1 (253:3): 0 60484 linear /dev/loop0 63
  # add map loop0p2 (253:4): 0 436224 linear /dev/loop0 61440
  # add map loop0p3 (253:5): 0 6144 linear /dev/loop0 499712
  # add map loop0p4 (253:6): 0 2 linear /dev/loop0 507904
  # add map loop0p5 (253:7): 0 747893 linear /dev/loop0 507967
  # add map loop0p6 (253:8): 0 122880 linear /dev/loop0 1257472
  # add map loop0p7 (253:9): 0 6144 linear /dev/loop0 1382400
  # add map loop0p8 (253:10): 0 6144 linear /dev/loop0 1390592
  # add map loop0p9 (253:11): 0 6144 linear /dev/loop0 1398784
  kpartx_output=$(kpartx -va ${disk_filename})
  echo "${kpartx_output}"
  _lsdevmaps=$(echo "${kpartx_output}"| egrep -v 'gpt:|dos:' | egrep -w add | awk '{print $3}')

  udevadm settle
}

function unmapptab() {
  #
  # Destroy all mapping devices
  #
  # Unsets L{Partition}s' and L{Filesystem}s' filename attribute
  #
  local disk_filename=$1
  [[ -a "${disk_filename}" ]] || { echo "file not found: ${disk_filename} (disk:${LINENO})" >&2; return 1; }
  checkroot || return 1

  local tries=0 max_tries=3
  while [[ "${tries}" -lt "${max_tries}" ]]; do
    kpartx -vd ${disk_filename} && break || :
    let tries++
    sleep 1
  done
  # # kpartx -vd ./centos-6.3_x86_64.raw
  # del devmap : loop0p9
  # del devmap : loop0p8
  # del devmap : loop0p7
  # del devmap : loop0p6
  # del devmap : loop0p5
  # del devmap : loop0p4
  # del devmap : loop0p3
  # del devmap : loop0p2
  # del devmap : loop0p1
  # loop deleted : /dev/loop0
  kpartx -vd ${disk_filename}

  while read parted_oldmap; do
    # '2>/dev/null' means if device does not exist,
    # dmsetup shows "Command failed" to stderr.
    # # dmsetup info ${parted_oldmap}
    # Command failed
    dmsetup info ${parted_oldmap} 2>/dev/null | egrep ^State: | egrep -w ACTIVE -q || continue
    printf "[DEBUG] Removing parted old map with 'dmsetup remove %s'\n" ${parted_oldmap}
    dmsetup remove ${parted_oldmap}
  done < <(lsdevmap ${disk_filename})

  while read devname; do
    local loop_device=/dev/${devname}
    # '2>/dev/null' means if device does not exist,
    # losetup shows "loop: can't get info on device /dev/loopX: No such device or address"
    # # losetup --show ${loop_device}
    # loop: can't get info on device /dev/loop6: No such device or address
    losetup --show ${loop_device} 2>/dev/null || continue
    printf "[DEBUG] Removing mapped loop device with 'losetup -d %s'\n" ${loop_device}
    losetup -d ${loop_device}
  done < <(lsdevmap ${disk_filename} | sed 's,p[0-9]*$,,' | sort | uniq)
}

declare _lsdevmaps=
function lsdevmap() {
  local disk_filename=$1
  [[ -a "${disk_filename}" ]] || { echo "file not found: ${disk_filename} (disk:${LINENO})" >&2; return 1; }
  checkroot || return 1

  # # kpartx -l ${disk_filename}
  # loop0p1 : 0 60484 /dev/loop0 63
  # loop0p2 : 0 436224 /dev/loop0 61440
  # loop0p3 : 0 6144 /dev/loop0 499712
  # loop0p4 : 0 2 /dev/loop0 507904
  # loop0p5 : 0 747893 /dev/loop0 507967
  # loop0p6 : 0 122880 /dev/loop0 1257472
  # loop0p7 : 0 6144 /dev/loop0 1382400
  # loop0p8 : 0 6144 /dev/loop0 1390592
  # loop0p9 : 0 6144 /dev/loop0 1398784
  # # kpartx -l ${disk_filename} | egrep -v "^(gpt|dos):" | awk '{print $1}'
  # loop0p1
  # loop0p2
  # loop0p3
  # loop0p4
  # loop0p5
  # loop0p6
  # loop0p7
  # loop0p8
  # loop0p9
  [[ -z "${_lsdevmaps}" ]] && {
    # $ man kpartx
    # >  -l     List partition mappings that would be added -a
    #
    # if showing devmap table without mapping file, file will be automatically mapped to loop device.
    # device mapping should be deleted.
    kpartx -l ${disk_filename} \
     | egrep -v "^(gpt|dos):" \
     | awk '{print $1}'
  } || {
    echo "${_lsdevmaps}"
  }
}

function devmap2path() {
  while read devmap; do
    case "${devmap}" in
    loop*)
      echo /dev/mapper/${devmap}
      ;;
    *)
      echo /dev/${devmap}
      ;;
    esac
  done < <(cat)
}

function devname2index() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (disk:${LINENO})" >&2; return 1; }

  local part_index=$(xptabinfo | cat -n | egrep -w ${name} | awk '{print $1}')
  case "${part_index}" in
  [1-3])
    echo ${part_index}
    ;;
  *)
    # part_index 4's part-type is "extended".
    # if part_index is more than 4, need to adjust part_index adding 1.
    echo $((${part_index} + 1))
    ;;
  esac
}

function mntpnt2path() {
  local disk_filename=$1 mountpoint=$2
  [[ -a "${disk_filename}" ]] || { echo "file not found: ${disk_filename} (disk:${LINENO})" >&2; return 1; }
  [[ -n "${mountpoint}" ]] || { echo "[ERROR] Invalid argument: mountpoint:${mountpoint} (disk:${LINENO})" >&2; return 1; }

  lsdevmap ${disk_filename} | devmap2path | egrep "$(devname2index "${mountpoint}")\$"
}

function mntpntuuid() {
  local disk_filename=$1 mountpoint=$2
  [[ -a "${disk_filename}" ]] || { echo "file not found: ${disk_filename} (disk:${LINENO})" >&2; return 1; }
  [[ -n "${mountpoint}" ]] || { echo "[ERROR] Invalid argument: mountpoint:${mountpoint} (disk:${LINENO})" >&2; return 1; }
  checkroot || return 1

  local part_filename=$(mntpnt2path ${disk_filename} ${mountpoint})
  blkid -c /dev/null -sUUID -ovalue ${part_filename}
}

function mkfsdisk() {
  #
  # Creates the partitions' filesystems
  #
  local disk_filename=$1
  [[ -a "${disk_filename}" ]] || { echo "file not found: ${disk_filename} (disk:${LINENO})" >&2; return 1; }
  checkroot || return 1

  printf "[INFO] Creating file systems\n"
  xptabproc <<'EOS'
    printf "[DEBUG] Creating file system: \"%s\" of size: %dMB\n" ${mountpoint} ${partsize}
    part_filename=$(mntpnt2path ${disk_filename} ${mountpoint})
    case "${mountpoint}" in
    swap)
      # > mkswap: /dev/mapper/loop0p7: warning: don't erase bootbits sectors
      # >  on whole disk. Use -f to force.
      mkswap -f ${part_filename}
      ;;
    *)
      mkfs.ext4 -F -E lazy_itable_init=1 -L ${mountpoint} ${part_filename}
      # > This filesystem will be automatically checked every 37 mounts or 180 days, whichever comes first.
      # > Use tune2fs -c or -i to override.
      [ ! "${max_mount_count:-37}" -eq 37 -o ! "${interval_between_check:-180}" -eq 180 ] && {
        printf "[INFO] Setting maximal mount count: %s\n" ${max_mount_count}
        printf "[INFO] Setting interval between check(s): %s\n" ${interval_between_check}
        tune2fs -c ${max_mount_count} -i ${interval_between_check} ${part_filename}
      }
      ;;
    esac
    # Let udev have a chance to extract the UUID for us
    udevadm settle
EOS
}

function get_grub_id() {
  #
  # Return name of the disk as known by grub
  #
  echo 0
}
