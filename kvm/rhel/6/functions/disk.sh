# -*-Shell-script-*-
#
# description:
#  Virtual disk management
#
# requires:
#  bash
#  truncate, rm
#  mkdir, mknod, mount, umount
#  cat, egrep, awk
#  parted, kpartx, udevadm, blkid
#  mkfs.ext4, tune2fs, mkswap
#  VBoxManage, qemu-img, kvm-img
#  losetup, dmsetup
#
# imports:
#  utils: checkroot
#

function add_option_disk() {
  max_mount_count=${max_mount_count:-37}
  interval_between_check=${interval_between_check:-180}

  rootsize=${rootsize:-4096}
  bootsize=${bootsize:-0}
  optsize=${optsize:-0}
  swapsize=${swapsize:-1024}
  homesize=${homesize:-0}
  usrsize=${usrsize:-0}
  varsize=${varsize:-0}
  tmpsize=${tmpsize:-0}

  xpart=${xpart:-}

  chroot_dir=${chroot_dir:-/tmp/tmp$(date +%s)}

  distro=${distro_name}-${distro_ver}_${distro_arch}
  distro_dir=${distro_dir:-${PWD}/${distro}}
  raw=${raw:-${PWD}/${distro}.raw}
  rootfs_dir=${rootfs_dir:-${PWD}/rootfs}
  diskless=${diskless:-}
}

## utils

function is_dev() {
  local disk_filename=$1
  # do not use "-a" in this case.
  [[ -n "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  case "${disk_filename}" in
  /dev/*) return 0 ;;
       *) return 1 ;;
  esac
}

function is_dmdev() {
  local disk_filename=$1
  # do not use "-a" in this case.
  [[ -n "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  disk_filename=$(extract_path ${disk_filename})

  case "${disk_filename}" in
  /dev/dm-[0-9]*) return 0 ;;
               *) return 1 ;;
  esac
}

function inodeof() {
  local filepath=$1
  [[ -a "${filepath}" ]] || { echo "[ERROR] file not found: ${filepath} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  stat --format=%i ${filepath}
}

function get_suffix() {
  [[ -n "${1}" ]] || { echo "[ERROR] Invalid argument: empty (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  echo ${1##*.}
}

## disk

function mkdisk() {
  #
  # Creates the disk image (if it doesn't already exist).
  #
  local disk_filename=$1 size=${2:-0} unit=${3:-m}
  [[ -a "${disk_filename}" ]] && { echo "[ERROR] already exists: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ "${size}" -gt 0 ]] || { echo "[ERROR] Invalid argument: size:${size} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  truncate -s ${size}${unit} ${disk_filename}
}

## filesystem

function mkdevice() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  while read name mode; do
    [[ -d "${chroot_dir}${name}" ]] || \
      mkdir -m ${mode} ${chroot_dir}${name}
  done < <(cat <<-EOS | egrep -v '^#|^$'
	# common
	/dev      755
	/sys      755
	# container
	/dev/pts  755
	/dev/shm 1777
	EOS
	)

  while read name mode type major minor; do
    [[ -a ${chroot_dir}/dev/${name} ]] || \
      mknod -m ${mode} ${chroot_dir}/dev/${name} ${type} ${major} ${minor}
  done < <(cat <<-EOS | egrep -v '^#|^$'
	# common
	null    666 c 1 3
	zero    666 c 1 5
	tty1    620 c 4 1
	tty2    620 c 4 2
	tty3    620 c 4 3
	tty4    620 c 4 4
	console 600 c 5 1
	# container
	full    666 c 1 7
	random  666 c 1 8
	urandom 666 c 1 9
	ptmx    666 c 5 2
	EOS
	)
}

function mkprocdir() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  mkdir ${chroot_dir}/proc
}

function mount_proc() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  printf "[DEBUG] Mounting %s\n" ${chroot_dir}/proc
  mount --bind /proc ${chroot_dir}/proc
}

function mount_sys() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  printf "[DEBUG] Mounting %s\n" ${chroot_dir}/sys
  mount --bind /sys ${chroot_dir}/sys
}

function mount_dev() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  printf "[DEBUG] Mounting %s\n" ${chroot_dir}/dev
  mount --bind /dev ${chroot_dir}/dev
}

function umount_root() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  printf "[DEBUG] Unmounting %s\n" ${chroot_dir}
  umount -l ${chroot_dir}
}

function after_umount_nonroot() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
}

function umount_nonroot() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  local mountpoint=
  while read mountpoint; do
    printf "[DEBUG] Unmounting %s\n" ${mountpoint}
    umount -l ${mountpoint}
  done < <(egrep ${chroot_dir}/ /etc/mtab | awk '{print $2}')

  after_umount_nonroot ${chroot_dir}
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
	/tmp  ${tmpsize:-0}
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

function sum_disksize() {
  xptabinfo | awk 'BEGIN {sum = 0} {sum += $2} END {print sum}'
}

function mkpart() {
  #
  # Adds partition to the disk image (does not mkfs or anything like that)
  #
  # fstype: should allow empty for extended parttype
  local disk_filename=$1 parttype=${2:-primary} offset=${3:-0} size=${4:-0} fstype=${5:-}
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  #
  # size == -1 or size > 0. "-1" means whole disk
  #
  [[ ("${size}" == -1) || ("${size}" -gt 0) ]] || { echo "[ERROR] Invalid argument: size:${size} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  case "${parttype}" in
  primary)
    ;;
  logical)
    ;;
  extended)
    ;;
  *)
    echo "[ERROR] Invalid parttype: ${parttype} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
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
    echo "[ERROR] Invalid fstype: ${fstype} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
    return 1
    ;;
  esac

  # parted default unit is not "mib" but "mb"
  local unit=mib
  local partition_start=${offset}                  unit_start=${unit}
  local partition_end=$((${offset} + ${size} - 1)) unit_end=${unit}

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
      echo "[ERROR] Invalid parttype: ${parttype} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
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
    partition_start=$((${partition_start} + 63))
    unit_start=s
  } || :

  # whole disk
  [[ "${size}" == -1 ]] && {
    partition_end=-1
    unit_end=
  }

  printf "[INFO] Adding type %s partition to disk image: %s\n" ${fstype} ${disk_filename}
  parted --script -- ${disk_filename} mkpart ${parttype} ${fstype} ${partition_start}${unit_start} ${partition_end}${unit_end}
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
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

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

function is_mapped() {
  local disk_filename=$1 opts=${2:-}
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  local inode=$(inodeof ${disk_filename})

  # # losetup -a
  # /dev/loop0: [fd02]:9044139 (./centos-6.3_x86_64.raw)
  losetup -a | egrep "\]:${inode} " ${opts}
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
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
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

  # already mapped?
  is_mapped ${disk_filename} -q && {
    echo "[WARN] already mapped: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})"
    return 2
  } || :

  # not mapped
  kpartx -va ${disk_filename}

  udevadm settle
}

function unmapptab() {
  #
  # Destroy all mapping devices
  #
  # Unsets L{Partition}s' and L{Filesystem}s' filename attribute
  #
  local disk_filename=$1
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  # *** don't save 'lsdevmap_output' at this line ***
  [[ -n "$(lsdevmap ${disk_filename})" ]] || {
    echo "[WARN] not mapped: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})"
    return 2
  }

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

  local lsdevmap_output="$(lsdevmap ${disk_filename})"
  [[ -n "${lsdevmap_output}" ]] || return 0
  echo "[WARN] still mapped: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})"

  while read parted_oldmap; do
    # '2>/dev/null' means if device does not exist,
    # dmsetup shows "Command failed" to stderr.
    # # dmsetup info ${parted_oldmap}
    # Command failed
    dmsetup info ${parted_oldmap} 2>/dev/null | egrep ^State: | egrep -w ACTIVE -q || continue
    printf "[DEBUG] Removing parted old map with 'dmsetup remove %s'\n" ${parted_oldmap}
    # TODO: ***work-around***
    # - easy to fail not to wait for a few seconds
    sleep 3
    dmsetup remove ${parted_oldmap}
  done < <(echo "${lsdevmap_output}")

  while read devname; do
    [[ -n "${devname}" ]] || continue
    local loop_device=/dev/${devname}
    # '2>/dev/null' means if device does not exist,
    # losetup shows "loop: can't get info on device /dev/loopX: No such device or address"
    # # losetup --show ${loop_device}
    # loop: can't get info on device /dev/loop6: No such device or address
    losetup --show ${loop_device} 2>/dev/null || continue
    printf "[DEBUG] Removing mapped loop device with 'losetup -d %s'\n" ${loop_device}
    losetup -d ${loop_device}
  done < <(echo "${lsdevmap_output}" | sed 's,p[0-9]*$,,' | sort | uniq)

  local mapped_lodev=$(mapped_lodev ${disk_filename})
  [[ -n "${mapped_lodev}" ]] || return 0

  losetup -d /dev/${mapped_lodev}
}

function mapped_lodev() {
  local disk_filename=$1
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  # /dev/loopXX mapped ?
  local mapped_names=$(is_mapped ${disk_filename}) || return 0

  # still mapped /dev/loopXX
  echo "${mapped_names}" | awk -F: '{print $1}' | sed "s,^/dev/,,"
}

function lsdevmap() {
  local disk_filename=$1
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  is_dev ${disk_filename} && {
    # # kpartx -l /dev/sda
    # sda1 : 0 1024000 /dev/sda 2048
    # sda2 : 0 485300224 /dev/sda 1026048

    kpartx -l ${disk_filename} \
     | egrep -v "^(gpt|dos):" \
     | awk '{print $1}'
  } || {
    local mapped_lodev=$(mapped_lodev ${disk_filename})
    [[ -n "${mapped_lodev}" ]] || return 0

    dmsetup ls | egrep ^${mapped_lodev} | awk '{print $1}'
  }
}

function devmap2path() {
  while read devmap; do
    case "${devmap}" in
    loop*)
      echo /dev/mapper/${devmap}
      ;;
    *p[0-9])
      # ex. LVM
      #
      # $ ls -la /dev/vbox/vbox1
      # lrwxrwxrwx 1 root root 7 Nov 20 14:54 /dev/vbox/vbox1 -> ../dm-0
      #
      # $ ls -la /dev/mapper/vbox-vbox1*
      # lrwxrwxrwx 1 root root 7 Nov 20 14:54 /dev/mapper/vbox-vbox1 -> ../dm-0
      # lrwxrwxrwx 1 root root 7 Nov 20 15:52 /dev/mapper/vbox-vbox1p1 -> ../dm-4
      # lrwxrwxrwx 1 root root 7 Nov 20 15:52 /dev/mapper/vbox-vbox1p2 -> ../dm-5
      #
      echo /dev/mapper/${devmap}
      ;;
    *)
      echo /dev/${devmap}
      ;;
    esac
  done < <(cat)
}

function devmap2lodev() {
  while read devmap; do
    case "${devmap}" in
    loop*)
      echo /dev/${devmap%p[0-9]*}
      ;;
    *)
      ;;
    esac
  done < <(cat) | sort | uniq
}

function devname2index() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  xptabinfo | cat -n | egrep -w "${name}" -q || { echo "[ERROR] no mutch keyword: ${name} (${BASH_SOURCE[0]##*/}:${LINENO})" >& 2; return 1; }

  local part_index=$(xptabinfo | cat -n | egrep -w "${name}" | awk '{print $1}')
  case "${part_index}" in
  "")
    echo "[ERROR] no such part_index" >&2
    return 1
    ;;
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
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${mountpoint}"    ]] || { echo "[ERROR] Invalid argument: mountpoint:${mountpoint} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  # 1# # lsdevmap ${disk_filename}
  # loop0p1
  # loop0p2
  #
  # 2# ... | devmap2path
  # /dev/mapper/loop0p1
  # /dev/mapper/loop0p2
  #
  # 3# devname2index root
  # 2
  #
  # > #{1} | #{2} | egrep "#{3}\$"

  lsdevmap ${disk_filename} | devmap2path | egrep "$(devname2index "${mountpoint}")\$"
}

function mntpntuuid() {
  local disk_filename=$1 mountpoint=$2
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${mountpoint}"    ]] || { echo "[ERROR] Invalid argument: mountpoint:${mountpoint} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  local part_filename=$(mntpnt2path ${disk_filename} ${mountpoint})
  blkid -c /dev/null -sUUID -ovalue ${part_filename}
}

function mkfsdisk() {
  #
  # Creates the partitions' filesystems
  #
  local disk_filename=$1 default_filesystem=$2
  [[ -a "${disk_filename}"      ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${default_filesystem}" ]] || { echo "[ERROR] Invalid argument: default_filesystem:${default_filesystem} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  max_mount_count=${max_mount_count:-37}
  interval_between_check=${interval_between_check:-180}

  printf "[INFO] Creating file systems\n"
  xptabproc <<'EOS'
    printf "[DEBUG] Creating file system: \"%s\" of size: %dMB\n" ${mountpoint} ${partsize}
    part_filename=$(mntpnt2path ${disk_filename} ${mountpoint})
    case "${mountpoint}" in
    swap)
      # > mkswap: /dev/mapper/loop0p7: warning: don't erase bootbits sectors
      # >  on whole disk. Use -f to force.
      mkswap -L ${mountpoint} -f ${part_filename}
      ;;
    *)
      local cmd="$(mkfs_fstype ${default_filesystem}) -L ${mountpoint} ${part_filename}"
      eval ${cmd}
      # > This filesystem will be automatically checked every 37 mounts or 180 days, whichever comes first.
      # > Use tune2fs -c or -i to override.
      [[ ("${max_mount_count}" != 37) || ("${interval_between_check}" != 180) ]] && {
        printf "[INFO] Setting maximal mount count: %s\n" ${max_mount_count}
        printf "[INFO] Setting interval between check(s): %s\n" ${interval_between_check}
        tune2fs -c ${max_mount_count} -i ${interval_between_check} ${part_filename}
      }
      # > $ tune2fs -l ${part_filename}
      # > Default mount options:    acl
      tune2fs -o acl ${part_filename}
      ;;
    esac
    # Let udev have a chance to extract the UUID for us
    udevadm settle
EOS
}

function mkfs_fstype() {
  local fstype=$1
  [[ -n "${fstype}" ]] || { echo "[ERROR] Invalid argument: fstype:${fstype} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  case "${fstype}" in
  ext3)
    echo mkfs.ext3 -F -I 128
    ;;
  ext4)
    echo mkfs.ext4 -F -E lazy_itable_init=1
    ;;
  *)
    echo "[ERROR] Invalid fstype: ${fsype} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
    return 1
    ;;
  esac
}

function get_grub_id() {
  #
  # Return name of the disk as known by grub
  #
  echo 0
}

function validate_image_format_type() {
  local image_format=$1
  [[ -n "${image_format}" ]] || { echo "[ERROR] file not image_format: ${image_format} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  case "${image_format}" in
  qcow2|vdi|vmdk)
    ;;
  *)
   echo "[ERROR] not supported image format: ${image_format} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
   return 1
   ;;
  esac
}

function convert_disk() {
  #
  # Convert the disk image
  #
  local disk_filename=$1 dest_dir=${2:-${PWD}} dest_format=${3:-vdi}
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  validate_image_format_type ${dest_format} || return 1

  # build dest_filename
  local base_filename=${disk_filename##*/}
  local dest_filename=${dest_dir}/${base_filename%%.$(get_suffix ${disk_filename})}.${dest_format}

  printf "[INFO] Converting %s to %s, format %s\n" ${disk_filename} ${dest_filename} ${dest_format}
  case "${dest_format}" in
  vdi)
    # TODO: add "vbox_manager_path" function to detect path
    VBoxManage convertfromraw -format VDI ${disk_filename} ${dest_filename}
    ;;
  *)
    $(qemu_img_path) convert -O ${dest_format} ${disk_filename} ${dest_filename}
    ;;
  esac
}

function qemu_img_path() {
  local execs="/usr/bin/qemu-img /usr/bin/kvm-img"

  local command_path=
  for exe in ${execs}; do
    [[ -x "${exe}" ]] && command_path=${exe} || :
  done

  [[ -n "${command_path}" ]] || { echo "[ERROR] command not found: ${execs} (${BASH_SOURCE[0]##*/}:${LINENO})." >&2; return 1; }
  echo ${command_path}
}
