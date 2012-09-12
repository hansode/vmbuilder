#!/bin/bash
#
# requires:
#  bash
#  tr, dirname, pwd
#  sed, head
#  build_rootfs_tree.sh
#  cat, truncate, dd, parted, kpartx, udevadm, blkid
#  mkfs, tune2fs, mkswap
#  mount, umount, mkdir, rmdir
#  rsync, sync, touch, ln, rm
#  chroot, grub, setarch
#  losetup, dmsetup
#
# memo:
#
# <based on vmbuilder>
#
# NAME
#        vmbuilder - builds virtual machines from the command line
#
# SYNOPSIS
#        vmbuilder [OPTIONS]...
#
# OPTIONS
#
#    Guest partitioning options
#        --part=PATH
#               Allows to specify a partition table in PATH each line of partfile should specify (root first):
#                       mountpoint size (device) (filename)
#               one  per  line, separated by space, where size is in megabytes. The third and fourth options allow you to specify a device for the filesystem, and a name for the filesystem image, both of which
#               are optional. You can have up to 4 virtual disks, a new disk starts on a line containing only '---'. ie:
#                       root 2000 a1 rootfs
#                       /boot 512 a2 boot
#                       swap 1000 a3 swapfs
#                       ---
#                       /var 8000 b1 var
#                       /var/log 2000 b2 varlog
#
#        The following three options are not used if --part is specified:
#
#               --rootsize=SIZE
#                      Size (in MB) of the root filesystem [default: 4096].  Discarded when --part is used.
#
#               --optsize=SIZE
#                      Size (in MB) of the /opt filesystem. If not set, no /opt filesystem will be added. Discarded when --part is used.
#
#               --swapsize=SIZE
#                      Size (in MB) of the swap partition [default: 1024]. Discarded when --part is used.
#
#   Network related options:
#       --ip=ADDRESS
#              IP address in dotted form [default: dhcp]
#
#       Options below are discarded if --ip is not specified
#              --mask=VALUE IP mask in dotted form [default: based on ip setting].
#
#              --net=ADDRESS
#                     IP net address in dotted form [default: based on ip setting].
#
#              --bcast=VALUE
#                     IP broadcast in dotted form [default: based on ip setting].
#
#              --gw=ADDRESS
#                     Gateway (router) address in dotted form [default: based on ip setting (first valid address in the network)].
#
#              --dns=ADDRESS
#                     DNS address in dotted form [default: based on ip setting (first valid address in the network)]
#
#    Post install actions:
#        --execscript=SCRIPT
#               Run SCRIPT after distro installation finishes. Script will be called with the guest's chroot as first argument, so you can use chroot $1 <cmd> to  run  code  in
#               the virtual machine.
#
#
# <based on tune2fs>
#
#       --max-mount-count=COUNT
#              Adjust the number of mounts after which the filesystem will be checked by e2fsck(8).  If max-mount-counts is 0 or  -1,  the  number  of  times  the
#              filesystem is mounted will be disregarded by e2fsck(8) and the kernel.
#
#              Staggering  the  mount-counts  at  which filesystems are forcibly checked will avoid all filesystems being checked at one time when using journaled
#              filesystems.
#
#              You should strongly consider the consequences of disabling mount-count-dependent checking entirely.  Bad disk drives, cables,  memory,  and  kernel
#              bugs  could  all  corrupt  a  filesystem  without  marking  the filesystem dirty or in error.  If you are using journaling on your filesystem, your
#              filesystem will never be marked dirty, so it will not normally be checked.  A filesystem error detected by the kernel will still force an  fsck  on
#              the next reboot, but it may already be too late to prevent data loss at that point.
#
#              See also the -i option for time-dependent checking.
#
#       --interval-between-check=COUNT
#              Adjust the maximal time between two filesystem checks.  No suffix or d will interpret the number interval-between-checks as days, m as months,  and
#              w as weeks.  A value of zero will disable the time-dependent checking.
#
#              It  is  strongly  recommended  that  either  -c (mount-count-dependent) or -i (time-dependent) checking be enabled to force periodic full e2fsck(8)
#              checking of the filesystem.  Failure to do so may lead to filesystem corruption (due to bad disks, cables, memory, or kernel bugs) going unnoticed,
#              ultimately resulting in data loss or corruption.
#
set -e

## private functions

function extract_args() {
  CMD_ARGS=
  for arg in $*; do
    case $arg in
      --*=*)
        key=${arg%%=*}; key=$(echo ${key##--} | tr - _)
        value=${arg##--*=}
        eval "${key}=\"${value}\""
        ;;
      *)
        CMD_ARGS="${CMD_ARGS} ${arg}"
        ;;
    esac
  done
  # trim
  CMD_ARGS=${CMD_ARGS%% }
  CMD_ARGS=${CMD_ARGS## }
}

function dump_vers() {
  cat <<-EOS
	# debug
	debug="${debug}"
	dry_run="${dry_run}"
	# options
	distro_name="${distro_name}"
	distro_ver="${distro_ver}"
	distro_arch="${distro_arch}"
	distro="${distro}"
	distro_dir="${distro_dir}"
	keepcache="${keepcache}"
	max_mount_count="${max_mount_count}"
	interval_between_check="${interval_between_check}"
	rootsize="${rootsize}"
	bootsize="${bootsize}"
	optsize="${optsize}"
	swapsize="${swapsize}"
	homesize="${homesize}"
	xpart="${xpart}"
	execscript="${execscript}"
	raw="${raw}"
	ip="${ip}"
	mask="${mask}"
	bcast="${bcast}"
	gw="${gw}"
	dns="${dns}"
	hostname="${hostname}"
	# required commands
	build_rootfs_tree_sh="${build_rootfs_tree_sh}"
	cat="${cat}"
	truncate="${truncate}"
	dd="${dd}"
	parted="${parted}"
	kpartx="${kpartx}"
	udevadm="${udevadm}"
	blkid="${blkid}"
	mkfs="${mkfs}"
	tune2fs="${tune2fs}"
	mkswap="${mkswap}"
	mount="${mount}"
	umount"=${umount}"
	mkdir="${mkdir}"
	rmdir="${rmdir}"
	rsync="${rsync}"
	sync="${sync}"
	sed="${sed}"
	touch="${touch}"
	ln="${ln}"
	rm="${rm}"
	chroot="${chroot}"
	grub="${grub}"
	setarch="${setarch}"
	losetup="${losetup}"
	dmsetup="${dmsetup}"
	EOS
}

function build_vers() {
  debug=${debug:-}
  [[ -z "${debug}" ]] || set -x
  dry_run=${dry_run:-}

  distro_name=${distro_name:-centos}
  distro_ver=${distro_ver:-6.3}

  distro_arch=${distro_arch:-$(arch)}
  case "${distro_arch}" in
  i*86)   distro_arch=i686;;
  x86_64) ;;
  esac

  distro=${distro_name}-${distro_ver}_${distro_arch}
  distro_dir=${distro_dir:-${abs_path}/${distro}}

  keepcache=${keepcache:-0}
  # keepcache should be [ 0 | 1 ]
  case "${keepcache}" in
  [01]) ;;
  *)    keepcache=0 ;;
  esac

  # requires:
  build_rootfs_tree_sh=${build_rootfs_tree_sh:-"${abs_path}/build-rootfs-tree.sh"}
  cat=${cat:-"cat"}
  truncate=${truncate:-"truncate"}
  dd=${dd-"dd"}
  parted=${parted:-"parted"}
  kpartx=${kpartx:-"kpartx"}
  udevadm=${udevadm:-"udevadm"}
  blkid=${blkid:-"blkid"}
  mkfs=${mkfs:-"mkfs.ext4"}
  tune2fs=${tune2fs:-"tune2fs"}
  mkswap=${mkswap:-"mkswap"}
  mount=${mount:-"mount"}
  umount=${umount:-"umount"}
  mkdir=${mkdir:-"mkdir"}
  rmdir=${rmdir:-"rmdir"}
  rsync=${rsync:-"rsync"}
  sync=${sync:-"sync"}
  sed=${sed:-"sed"}
  touch=${touch:-"touch"}
  ln=${ln:-"ln"}
  rm=${rm:-"rm"}
  chroot=${chroot:-"chroot"}
  grub=${grub:-"grub"}
  setarch=${setarch:-"setarch"}
  losetup=${losetup:-"losetup"}
  dmsetup=${dmsetup:-"dmsetup"}

  [[ -n ${dry_run} ]] && {
    build_rootfs_tree_sh="echo ${abs_path}/build-rootfs-tree.sh"
    cat="echo ${cat}"
    truncate="echo ${truncate}"
    dd="echo ${dd}"
    parted="echo ${parted}"
    kpartx="echo ${kpartx}"
    udevadm="echo ${udevadm}"
    blkid="echo ${blkid}"
    mkfs="echo ${mkfs}"
    tune2fs="echo ${tune2fs}"
    mkswap="echo ${mkswap}"
    mount="echo ${mount}"
    umount="echo ${umount}"
    mkdir="echo ${mkdir}"
    rmdir="echo ${rmdir}"
    rsync="echo ${rsync}"
    sync="echo ${sync}"
    sed="echo ${sed}"
    touch="echo ${touch}"
    ln="echo ${ln}"
    rm="echo ${rm}"
    chroot="echo ${chroot}"
    grub="echo ${grub}"
    setarch="echo ${setarch}"
    losetup="echo ${losetup}"
    dmsetup="echo ${dmsetup}"
  } || :

  # * tune2fs
  # > This filesystem will be automatically checked every 37 mounts or 180 days, whichever comes first.
  # > Use tune2fs -c or -i to override.
  max_mount_count=${max_mount_count:-37}
  interval_between_check=${interval_between_check:-180}

  rootsize=${rootsize:-4096}
  bootsize=${bootsize:-0}
  optsize=${optsize:-0}
  swapsize=${swapsize:-1024}
  homesize=${homesize:-0}
  totalsize=$((${rootsize} + ${optsize} + ${swapsize} + ${homesize}))

  xpart=${xpart:-}
  execscript=${execscript:-}
  raw=${raw:-./${distro}.raw}

  #domain=${domain:-}
  ip=${ip:-}
  mask=${mask:-}
  net=${net:-}
  bcast=${bcast:-}
  gw=${gw:-}
  dns=${dns:-}
  hostname=${hostname:-}
}

## private functions for partition map

function pmapindex() {
  local name=$1
  [[ -n ${name} ]] || return 1
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

function ppartpath() {
  local disk_filename=$1 mountpoint=$2
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  [[ -n ${mountpoint} ]] || return 1
  lsdevmap ${disk_filename} | devmap2path | egrep "$(pmapindex "${mountpoint}")\$"
}

function ppartuuid() {
  local disk_filename=$1 mountpoint=$2
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  local part_filename=$(ppartpath ${disk_filename} ${mountpoint})
  ${blkid} -c /dev/null -sUUID -ovalue ${part_filename}
}

## rootfs tree

function mkrootfs() {
  local distro_dir=$1

  [[ -d "${distro_dir}" ]] && {
    printf "[INFO] already exists: %s\n" ${distro_dir}
  } || {
    printf "[INFO] Building OS tree: %s\n" ${distro_dir}
    ${build_rootfs_tree_sh} \
     --distro-name=${distro_name} \
     --distro-ver=${distro_ver}   \
     --distro-arch=${distro_arch} \
     --chroot-dir=${distro_dir}   \
     --keepcache=${keepcache}     \
     --batch=1                    \
     --debug=1
  }
}

## disk

function mkdisk() {
  local disk_filename=$1 size=$2 unit=${3:-m}
  [[ -a ${disk_filename} ]] && { echo "already exists: ${disk_filename}" >&2; return 1; }
  ${truncate} -s ${size}${unit} ${disk_filename}
}

function rmdisk() {
  local disk_filename=$1
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  ${rm} -f ${disk_filename}
}

## mbr(master boot record)

function rmmbr() {
  local disk_filename=$1
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  ${dd} if=/dev/zero of=${disk_filename} bs=512 count=1
}

## ptab

function xptabinfo() {
  {
    [[ -n "${xpart}" ]] && [[ -f "${xpart}" ]] && {
      ${cat} ${xpart}
    } || {
      ${cat} <<-EOS
	#
	# totalsize:${totalsize}
	#
	/boot ${bootsize}
	root  ${rootsize}
	swap  ${swapsize}
	/opt  ${optsize}
	/home ${homesize}
	EOS
    }
  } | egrep -v '^$|^#' | awk '$2 != 0 {print $1, $2}'
}

function mkpart() {
  local disk_filename=$1 parttype=$2 offset=$3 size=$4 fstype=$5
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }

  case "${fstype}" in
  ext2) ;;
  swap) fstype="linux-swap(new)" ;;
  esac

  local partition_start=${offset}
  local partition_end=$((${offset} + ${size} - 1))
  local previous_partition=$(${parted} --script -- ${disk_filename} unit s print | egrep -v '^$' | awk '$1 ~ "^[1-9]+"' | tail -1)

  case "${previous_partition}" in
  # 1st primary
  "") ;;
  # 1st logical
  *extended) partition_start=$(echo "${previous_partition}" | awk '{print $2}' | sed 's,s$,,') ;;
  # others
  *) false ;;
  esac && {
    printf "[INFO] Partition at beginning of disk - reserving first cylinder\n"
    partition_start=$((${partition_start} + 63))s
  } || :

  # whole disk
  [[ ${size} == -1 ]] && {
    partition_end=-1
  }

  printf "[INFO] Adding type %s partition to disk image: %s\n" ${fstype} ${disk_filename}
  ${parted} --script -- ${disk_filename} mkpart ${parttype} ${fstype} ${partition_start} ${partition_end}
  # for physical /dev/XXX
  ${udevadm} settle
}

function mkptab() {
  local disk_filename=$1
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }

  printf "[INFO] Adding partition table to disk image: %s\n" ${disk_filename}
  ${parted} --script ${disk_filename} mklabel msdos

  local i=1 offset=0 parttype=
  while read mountpoint partsize; do
    case "${mountpoint}" in
    swap) fstype=swap;;
    *)    fstype=ext2;;
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
      ${parted} --script -- ${disk_filename} set ${i} lba off
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
      ${parted} --script -- ${disk_filename} set ${i} boot on
      ;;
    esac

    i=$((${i} + 1))
  done < <(xptabinfo)
}

function mapptab() {
  local disk_filename=$1
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  ${kpartx} -va ${disk_filename} && ${udevadm} settle
  # add map loop0p1 (253:3): 0 1998013 linear /dev/loop0 34
}

function unmapptab() {
  local disk_filename=$1
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  ${kpartx} -vd ${disk_filename}
  # del devmap : loop0p1
}

function unmapptab_r() {
  local disk_filename=$1
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  local tries=0 max_tries=3
  while [[ ${tries} -lt ${max_tries} ]]; do
    unmapptab ${disk_filename}  && break || :
    tries=$((${tries} + 1))
    sleep 1
  done
  unmapptab ${disk_filename}
}

function lsdevmap() {
  local disk_filename=$1
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  ${kpartx} -l ${disk_filename} \
   | egrep -v "^(gpt|dos):" \
   | awk '{print $1}'
}

function devmap2path() {
  cat | while read devmap; do
    case "${devmap}" in
    loop*)
      echo /dev/mapper/${devmap}
      ;;
    *)
      echo /dev/${devmap}
      ;;
    esac
  done
}

## vmimage

function mkfs2vm() {
  local disk_filename=$1
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }

  printf "[INFO] Creating file systems\n"
  while read mountpoint partsize; do
    printf "[DEBUG] Creating file system: %s\n" ${mountpoint}
    part_filename=$(ppartpath ${disk_filename} ${mountpoint})
    case "${mountpoint}" in
    swap)
      ${mkswap} ${part_filename}
      ;;
    *)
      ${mkfs} -F -E lazy_itable_init=1 ${part_filename}

      # > This filesystem will be automatically checked every 37 mounts or 180 days, whichever comes first.
      # > Use tune2fs -c or -i to override.
      [ ! "${max_mount_count}" -eq 37 -o ! "${interval_between_check}" -eq 180 ] && {
        printf "[INFO] Setting maximal mount count: %s\n" ${max_mount_count}
        printf "[INFO] Setting interval between check(s): %s\n" ${interval_between_check}
        ${tune2fs} -c ${max_mount_count} -i ${interval_between_check} ${part_filename}
      }
      ;;
    esac
    ${udevadm} settle
  done < <(xptabinfo)
}

function mountvm_root() {
  local disk_filename=$1 chroot_dir=$2
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  while read mountpoint partsize; do
    part_filename=$(ppartpath ${disk_filename} ${mountpoint})
    case "${mountpoint}" in
    root)
      printf "[DEBUG] Mounting %s\n" ${chroot_dir}
      ${mount} ${part_filename} ${chroot_dir}
      ;;
    esac
  done < <(xptabinfo)
}

function mountvm_nonroot() {
  local disk_filename=$1 chroot_dir=$2
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }

  while read mountpoint partsize; do
    part_filename=$(ppartpath ${disk_filename} ${mountpoint})
    case "${mountpoint}" in
    root|swap) ;;
    *)
      printf "[DEBUG] Mounting %s\n" ${chroot_dir}${mountpoint}
      [[ -d ${chroot_dir}${mountpoint} ]] || mkdir -p ${chroot_dir}${mountpoint}
      ${mount} ${part_filename} ${chroot_dir}${mountpoint}
      ;;
    esac
  done < <(xptabinfo)
}

function mountvm() {
  local disk_filename=$1 chroot_dir=$2
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  [[ -d "${chroot_dir}" ]] && { echo "already exists: ${chroot_dir}" >&2; return 1; }
  ${mkdir} -p ${chroot_dir}
  mountvm_root ${disk_filename} ${chroot_dir}
  mountvm_nonroot ${disk_filename} ${chroot_dir}
}

function umountvm_root() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  printf "[DEBUG] Unmounting %s\n" ${chroot_dir}
  ${umount} ${chroot_dir}
}

function umountvm_nonroot() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  egrep ${chroot_dir}/ /etc/mtab | awk '{print $2}' | while read mountpoint; do
    printf "[DEBUG] Unmounting %s\n" ${mountpoint}
    ${umount} ${mountpoint}
  done
}

function umountvm() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  umountvm_nonroot ${chroot_dir}
  umountvm_root    ${chroot_dir}
  ${rmdir} ${chroot_dir}
}

function installos() {
  local distro_dir=$1 disk_filename=$2
  [[ -d "${distro_dir}" ]] || { echo "no such directory: ${distro_dir}" >&2; exit 1; }
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }

  local chroot_dir=/tmp/tmp$(date +%s)

  mountvm ${disk_filename} ${chroot_dir}

  installdistro2vm     ${distro_dir} ${chroot_dir}
  installgrub2vm       ${chroot_dir} ${disk_filename}
  configure_networking ${chroot_dir}
  configure_mounting   ${chroot_dir} ${disk_filename}
  run_execscript       ${chroot_dir}

  umountvm             ${chroot_dir}
}

function installdistro2vm() {
  local distro_dir=$1 chroot_dir=$2
  [[ -d "${distro_dir}" ]] || { echo "no such directory: ${distro_dir}" >&2; exit 1; }
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }

  printf "[DEBUG] Installing OS to %s\n" ${chroot_dir}
  ${rsync} -aHA ${distro_dir}/ ${chroot_dir}
  ${sync}

  printf "[INFO] Setting /etc/yum.conf: keepcache=%s\n" ${keepcache}
  ${sed} -i s,^keepcache=.*,keepcache=${keepcache}, ${chroot_dir}/etc/yum.conf
}

function installgrub2vm() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }

  local tmpdir=/tmp/vmbuilder-grub
  ${mkdir} -p ${chroot_dir}/${tmpdir}

  local devmapfile=${tmpdir}/device.map
  ${touch} ${chroot_dir}/${devmapfile}

  local grub_id=0

  is_dev ${disk_filename} || {
    local new_filename=${tmpdir}/$(basename ${disk_filename})
    ${touch} ${chroot_dir}/${new_filename}
    ${mount} --bind ${disk_filename} ${chroot_dir}/${new_filename}
  }

  printf "[INFO] Generating %s.\n" ${devmapfile}
  is_dev ${disk_filename} && {
    printf "(hd%d) %s\n" ${grub_id} ${disk_filename}
  } || {
    printf "(hd%d) %s\n" ${grub_id} ${new_filename}
  } >> ${chroot_dir}/${devmapfile}
  ${cat} ${chroot_dir}/${devmapfile}

  printf "[INFO] Installing grub.\n"
  # install grub
  local grub_cmd=

  is_dev ${disk_filename} && {
    grub_cmd="${grub} --device-map=${chroot_dir}/${devmapfile} --batch"
  } || {
    grub_cmd="${chroot} ${chroot_dir} ${grub} --device-map=${devmapfile} --batch"
  }
  ${cat} <<-_EOS_ | ${grub_cmd}
	root (hd${grub_id},0)
	setup (hd0)
	quit
	_EOS_

  printf "[INFO] Generating /boot/grub/grub.conf.\n"
  local bootdir_path=/boot
  xptabinfo | egrep -q /boot && {
    bootdir_path=
  }
  ${cat} <<-_EOS_ > ${chroot_dir}/boot/grub/grub.conf
	default=0
	timeout=5
	splashimage=(hd${grub_id},0)${bootdir_path}/grub/splash.xpm.gz
	hiddenmenu
	title ${distro} ($(cd ${chroot_dir}/boot && ls vmlinuz-* | tail -1 | sed 's,^vmlinuz-,,'))
	        root (hd${grub_id},0)
	        kernel ${bootdir_path}/$(cd ${chroot_dir}/boot && ls vmlinuz-* | tail -1) ro root=UUID=$(ppartuuid ${disk_filename} root) rd_NO_LUKS rd_NO_LVM LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM
	        initrd ${bootdir_path}/$(cd ${chroot_dir}/boot && ls initramfs-*| tail -1)
	_EOS_
  ${cat} ${chroot_dir}/boot/grub/grub.conf
  cd ${chroot_dir}/boot/grub
  ${ln} -fs grub.conf menu.lst
  cd -

  is_dev ${disk_filename} || {
    printf "[DEBUG] Unmounting %s\n" ${chroot_dir}/${new_filename}
    ${umount} ${chroot_dir}/${new_filename}
  }

  printf "[DEBUG] Deleting %s\n" ${chroot_dir}/${tmpdir}
  ${rm} -rf ${chroot_dir}/${tmpdir}
}

function configure_networking() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }

  # /etc/sysconfig/network-scripts/ifcfg-eth0
  [[ -z "${ip}" ]] || {
    printf "[INFO] Unsetting /etc/sysconfig/network-scripts/ifcfg-eth0.\n"
    ${cat} <<-_EOS_ > ${chroot_dir}/etc/sysconfig/network-scripts/ifcfg-eth0
	DEVICE=eth0
	BOOTPROTO=static
	ONBOOT=yes
	IPADDR=${ip}
	$([[ -z "${net}"   ]] || echo "NETMASK=${net}")
	$([[ -z "${bcast}" ]] || echo "BROADCAST=${bcast}")
	$([[ -z "${gw}"    ]] || echo "GATEWAY=${gw}")
	_EOS_
  }
  ${cat} ${chroot_dir}/etc/sysconfig/network-scripts/ifcfg-eth0

  # /etc/resolv.conf
  [[ -z "${dns}" ]] || {
    printf "[INFO] Unsetting /etc/resolv.conf.\n"
    ${cat} <<-_EOS_ > ${chroot_dir}/etc/resolv.conf
	nameserver ${dns}
	_EOS_
  }
  ${cat} ${chroot_dir}/etc/resolv.conf

  # hostname
  [[ -z "${hostname}" ]] || {
    printf "[INFO] Setting hostname: %s\n" ${hostname}
    egrep ^HOSTNAME= ${chroot_dir}/etc/sysconfig/network -q && {
      ${sed} -i "s,^HOSTNAME=.*,HOSTNAME=${hostname}," ${chroot_dir}/etc/sysconfig/network
    } || {
      echo HOSTNAME=${hostname} >> ${chroot_dir}/etc/sysconfig/network
    }
    ${cat} ${chroot_dir}/etc/sysconfig/network

    echo 127.0.0.1 ${hostname} >> ${chroot_dir}/etc/hosts
    ${cat} ${chroot_dir}/etc/hosts
  }

  # disable mac address caching
  printf "[INFO] Unsetting udev 70-persistent-net.rules.\n"
  ${rm} -f ${chroot_dir}/etc/udev/rules.d/70-persistent-net.rules
  ${ln} -s /dev/null ${chroot_dir}/etc/udev/rules.d/70-persistent-net.rules
}

function configure_mounting() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }

  printf "[INFO] Overwriting /etc/fstab.\n"
  {
  while read mountpoint partsize; do
    case "${mountpoint}" in
    /boot) fstype=ext4 dumpopt=1 fsckopt=2 mountpath=${mountpoint} ;;
    root)  fstype=ext4 dumpopt=1 fsckopt=1 mountpath=/             ;;
    swap)  fstype=swap dumpopt=0 fsckopt=0 mountpath=${mountpoint} ;;
    /opt)  fstype=ext4 dumpopt=1 fsckopt=1 mountpath=${mountpoint} ;;
    /home) fstype=ext4 dumpopt=1 fsckopt=2 mountpath=${mountpoint} ;;
    *)     fstype=ext4 dumpopt=1 fsckopt=1 mountpath=${mountpoint} ;;
    esac

    uuid=$(ppartuuid ${disk_filename} ${mountpoint})
    printf "UUID=%s %s\t%s\tdefaults\t%s %s\n" ${uuid} ${mountpath} ${fstype} ${dumpopt} ${fsckopt}
  done < <(xptabinfo)

  ${cat} <<-_EOS_
	tmpfs                   /dev/shm                tmpfs   defaults        0 0
	devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
	sysfs                   /sys                    sysfs   defaults        0 0
	proc                    /proc                   proc    defaults        0 0
	_EOS_
  } > ${chroot_dir}/etc/fstab
  ${cat} ${chroot_dir}/etc/fstab
}

function run_execscript() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }

  [[ -n "${execscript}" ]] || {
    ${chroot} ${chroot_dir} bash -c "echo root:root | chpasswd"
    return 0
  }

  [[ -f "${execscript}" ]] || return 0
  [[ -x "${execscript}" ]] || return 0
  printf "[INFO] Excecuting after script\n"
  ${setarch} ${distro_arch} ${execscript} ${chroot_dir}
}

function is_dev() {
  local disk_filename=$1 mountpoint=$2
  # do not use "-a" in this case.
  [[ -n ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  case "${disk_filename}" in
  /dev/*) return 0 ;;
       *) return 1 ;;
  esac
}

## task

function task_rootfs() {
  mkrootfs ${distro_dir}
}

function task_prepare() {
  is_dev ${raw} && {
    rmmbr ${raw}
  } || {
    [[ -f ${raw} ]] && rmdisk ${raw}
    printf "[INFO] Creating disk image: \"%s\" of size: %dMB\n" ${raw} ${totalsize}
    mkdisk  ${raw} ${totalsize}
  }
}

function task_setup() {
  mkptab  ${raw}
  is_dev ${raw} || {
    printf "[INFO] Creating loop devices corresponding to the created partitions\n"
    mapptab ${raw}
  }
}

function task_build() {
  mkfs2vm ${raw}
}

function task_install() {
  installos ${distro_dir} ${raw}
}

function task_postinstall() {
  is_dev ${raw} || {
    printf "[INFO] Deleting loop devices\n"
    unmapptab_r ${raw}
  }
  printf "[INFO] Generated => %s\n" ${raw}
  printf "[INFO] Complete!\n"
}

function task_clean() {
  is_dev ${raw} && {
    rmmbr ${raw}
  } || {
    [[ -f ${raw} ]] && {
      printf "[INFO] Deleting disk image: \"%s\"\n" ${raw}
      rmdisk ${raw}
    }
  }
  # don't need to clean at least in this task.
  # [[ -d ${distro_dir} ]] && rm -rf ${distro_dir}
}

function task_status() {
  ${losetup} -a
  ${dmsetup} ls
}

function check_user() {
  [[ $UID -ne 0 ]] && {
    echo "[ERROR] Must run as root." >&2
    return 1
  } || :
}

### prepare

extract_args $*

### read-only variables

readonly abs_path=$(cd $(dirname $0) && pwd)

## main

build_vers
check_user
cmd="$(echo ${CMD_ARGS} | sed "s, ,\n,g" | head -1)"

case "${cmd}" in
debug|dump)
  dump_vers
  ;;
rootfs)
  task_rootfs
  ;;
prep|prepare)
  task_prepare
  ;;
setup)
  task_setup
  ;;
build)
  task_build
  ;;
install)
  task_install
  ;;
post|postinstall)
  task_postinstall
  ;;
clean)
  task_clean
  ;;
status)
  task_status
  ;;
soft-test)
  task_prepare
  task_setup
  task_build
  task_postinstall
  task_clean
  ;;
*)
  task_rootfs
  task_prepare
  task_setup
  task_build
  task_install
  task_postinstall
  ;;
esac
