#!/bin/bash
#
# requires:
#  bash
#  tr, dirname, pwd
#  sed, head
#  build_rootfs_tree.sh
#  cat, udevadm, blkid
#  mkfs.ext4, tune2fs, mkswap
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
  i*86)   distro_arch=i686 ;;
  x86_64) ;;
  esac

  distro=${distro_name}-${distro_ver}_${distro_arch}
  distro_dir=${distro_dir:-${abs_dirname}/${distro}}

  keepcache=${keepcache:-0}
  # keepcache should be [ 0 | 1 ]
  case "${keepcache}" in
  [01]) ;;
  *)    keepcache=0 ;;
  esac

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

  chroot_dir_path=${chroot_dir_path:-/tmp/tmp$(date +%s)}

  #domain=${domain:-}
  ip=${ip:-}
  mask=${mask:-}
  net=${net:-}
  bcast=${bcast:-}
  gw=${gw:-}
  dns=${dns:-}
  hostname=${hostname:-}
}

## private functions

function mkrootfs() {
  local distro_dir=$1

  [[ -d "${distro_dir}" ]] && {
    printf "[INFO] already exists: %s\n" ${distro_dir}
  } || {
    printf "[INFO] Building OS tree: %s\n" ${distro_dir}
    ${abs_dirname}/cebootstrap.sh \
     --distro-name=${distro_name} \
     --distro-ver=${distro_ver}   \
     --distro-arch=${distro_arch} \
     --chroot-dir=${distro_dir}   \
     --keepcache=${keepcache}     \
     --batch=1
  }
}

## vmimage

function mkfs2vm() {
  local disk_filename=$1
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }

  printf "[INFO] Creating file systems\n"
  xptabproc <<'EOS'
    printf "[DEBUG] Creating file system: \"%s\" of size: %dMB\n" ${mountpoint} ${partsize}
    part_filename=$(ppartpath ${disk_filename} ${mountpoint})
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
      [ ! "${max_mount_count}" -eq 37 -o ! "${interval_between_check}" -eq 180 ] && {
        printf "[INFO] Setting maximal mount count: %s\n" ${max_mount_count}
        printf "[INFO] Setting interval between check(s): %s\n" ${interval_between_check}
        tune2fs -c ${max_mount_count} -i ${interval_between_check} ${part_filename}
      }
      ;;
    esac
    udevadm settle
EOS
}

function mountvm_root() {
  local disk_filename=$1 chroot_dir=$2
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  xptabproc <<'EOS'
    part_filename=$(ppartpath ${disk_filename} ${mountpoint})
    case "${mountpoint}" in
    root)
      printf "[DEBUG] Mounting %s\n" ${chroot_dir}
      mount ${part_filename} ${chroot_dir}
      ;;
    esac
EOS
}

function mountvm_nonroot() {
  local disk_filename=$1 chroot_dir=$2
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }

  xptabproc <<'EOS'
    part_filename=$(ppartpath ${disk_filename} ${mountpoint})
    case "${mountpoint}" in
    root|swap) ;;
    *)
      printf "[DEBUG] Mounting %s\n" ${chroot_dir}${mountpoint}
      [[ -d ${chroot_dir}${mountpoint} ]] || mkdir -p ${chroot_dir}${mountpoint}
      mount ${part_filename} ${chroot_dir}${mountpoint}
      ;;
    esac
EOS
}

function mountvm() {
  local disk_filename=$1 chroot_dir=$2
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  [[ -d "${chroot_dir}" ]] && { echo "already exists: ${chroot_dir}" >&2; return 1; }
  mkdir -p ${chroot_dir}
  mountvm_root ${disk_filename} ${chroot_dir}
  mountvm_nonroot ${disk_filename} ${chroot_dir}
}

function umountvm() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  umount_nonroot ${chroot_dir}
  umount_root    ${chroot_dir}
  rmdir ${chroot_dir}
}

function installos() {
  local distro_dir=$1 disk_filename=$2
  [[ -d "${distro_dir}" ]] || { echo "no such directory: ${distro_dir}" >&2; exit 1; }
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }

  local chroot_dir=${chroot_dir_path}

  installdistro2vm     ${distro_dir} ${chroot_dir}
  installgrub2vm       ${chroot_dir} ${disk_filename}
  configure_networking ${chroot_dir}
  configure_mounting   ${chroot_dir} ${disk_filename}
}

function installdistro2vm() {
  local distro_dir=$1 chroot_dir=$2
  [[ -d "${distro_dir}" ]] || { echo "no such directory: ${distro_dir}" >&2; exit 1; }
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }

  printf "[DEBUG] Installing OS to %s\n" ${chroot_dir}
  rsync -aHA ${distro_dir}/ ${chroot_dir}
  sync

  printf "[INFO] Setting /etc/yum.conf: keepcache=%s\n" ${keepcache}
  sed -i s,^keepcache=.*,keepcache=${keepcache}, ${chroot_dir}/etc/yum.conf
}

function installgrub2vm() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }

  local tmpdir=/tmp/vmbuilder-grub
  mkdir -p ${chroot_dir}/${tmpdir}

  local grub_id=0

  is_dev ${disk_filename} || {
    local new_filename=${tmpdir}/$(basename ${disk_filename})
    touch ${chroot_dir}/${new_filename}
    mount --bind ${disk_filename} ${chroot_dir}/${new_filename}
  }

  local devmapfile=${tmpdir}/device.map
  touch ${chroot_dir}/${devmapfile}
  printf "[INFO] Generating %s\n" ${devmapfile}
  {
    is_dev ${disk_filename} && {
      printf "(hd%d) %s\n" ${grub_id} ${disk_filename}
    } || {
      printf "(hd%d) %s\n" ${grub_id} ${new_filename}
    }
  } >> ${chroot_dir}/${devmapfile}
  cat ${chroot_dir}/${devmapfile}

  printf "[INFO] Installing grub\n"
  # install grub
  local grub_cmd=

  is_dev ${disk_filename} && {
    grub_cmd="grub --device-map=${chroot_dir}/${devmapfile} --batch"
  } || {
    grub_cmd="chroot ${chroot_dir} grub --device-map=${devmapfile} --batch"
  }
  cat <<-_EOS_ | ${grub_cmd}
	root (hd${grub_id},0)
	setup (hd0)
	quit
	_EOS_

  printf "[INFO] Generating /boot/grub/grub.conf\n"
  local bootdir_path=/boot
  xptabinfo | egrep -q /boot && {
    bootdir_path=
  }
  cat <<-_EOS_ > ${chroot_dir}/boot/grub/grub.conf
	default=0
	timeout=5
	splashimage=(hd${grub_id},0)${bootdir_path}/grub/splash.xpm.gz
	hiddenmenu
	title ${distro} ($(cd ${chroot_dir}/boot && ls vmlinuz-* | tail -1 | sed 's,^vmlinuz-,,'))
	        root (hd${grub_id},0)
	        kernel ${bootdir_path}/$(cd ${chroot_dir}/boot && ls vmlinuz-* | tail -1) ro root=UUID=$(ppartuuid ${disk_filename} root) rd_NO_LUKS rd_NO_LVM LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM
	        initrd ${bootdir_path}/$(cd ${chroot_dir}/boot && ls initramfs-*| tail -1)
	_EOS_
  cat ${chroot_dir}/boot/grub/grub.conf
  cd ${chroot_dir}/boot/grub
  ln -fs grub.conf menu.lst
  cd -

  is_dev ${disk_filename} || {
    printf "[DEBUG] Unmounting %s\n" ${chroot_dir}/${new_filename}
    umount ${chroot_dir}/${new_filename}
  }

  printf "[DEBUG] Deleting %s\n" ${chroot_dir}/${tmpdir}
  rm -rf ${chroot_dir}/${tmpdir}
}

function configure_networking() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }

  printf "[INFO] Generating /etc/sysconfig/network-scripts/ifcfg-eth0\n"
  [[ -z "${ip}" ]] || {
    printf "[INFO] Unsetting /etc/sysconfig/network-scripts/ifcfg-eth0\n"
    cat <<-_EOS_ > ${chroot_dir}/etc/sysconfig/network-scripts/ifcfg-eth0
	DEVICE=eth0
	BOOTPROTO=static
	ONBOOT=yes
	IPADDR=${ip}
	$([[ -z "${net}"   ]] || echo "NETMASK=${net}")
	$([[ -z "${bcast}" ]] || echo "BROADCAST=${bcast}")
	$([[ -z "${gw}"    ]] || echo "GATEWAY=${gw}")
	_EOS_
  }
  cat ${chroot_dir}/etc/sysconfig/network-scripts/ifcfg-eth0

  printf "[INFO] Generating /etc/resolv.conf\n"
  # /etc/resolv.conf
  [[ -z "${dns}" ]] || {
    printf "[INFO] Unsetting /etc/resolv.conf\n"
    cat <<-_EOS_ > ${chroot_dir}/etc/resolv.conf
	nameserver ${dns}
	_EOS_
  }
  cat ${chroot_dir}/etc/resolv.conf

  # hostname
  [[ -z "${hostname}" ]] || {
    printf "[INFO] Setting hostname: %s\n" ${hostname}
    egrep ^HOSTNAME= ${chroot_dir}/etc/sysconfig/network -q && {
      sed -i "s,^HOSTNAME=.*,HOSTNAME=${hostname}," ${chroot_dir}/etc/sysconfig/network
    } || {
      echo HOSTNAME=${hostname} >> ${chroot_dir}/etc/sysconfig/network
    }
    cat ${chroot_dir}/etc/sysconfig/network

    echo 127.0.0.1 ${hostname} >> ${chroot_dir}/etc/hosts
    cat ${chroot_dir}/etc/hosts
  }

  # disable mac address caching
  printf "[INFO] Unsetting udev 70-persistent-net.rules\n"
  rm -f ${chroot_dir}/etc/udev/rules.d/70-persistent-net.rules
  ln -s /dev/null ${chroot_dir}/etc/udev/rules.d/70-persistent-net.rules
}

function configure_mounting() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }

  printf "[INFO] Overwriting /etc/fstab\n"
  {
  xptabproc <<'EOS'
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
EOS

  cat <<-_EOS_
	tmpfs                   /dev/shm                tmpfs   defaults        0 0
	devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
	sysfs                   /sys                    sysfs   defaults        0 0
	proc                    /proc                   proc    defaults        0 0
	_EOS_
  } > ${chroot_dir}/etc/fstab
  cat ${chroot_dir}/etc/fstab
}

function run_execscript() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }

  [[ -n "${execscript}" ]] || {
    chroot ${chroot_dir} bash -c "echo root:root | chpasswd"
    return 0
  }

  [[ -f "${execscript}" ]] || return 0
  [[ -x "${execscript}" ]] || return 0

  mount_proc ${chroot_dir}
  mount_dev  ${chroot_dir}

  printf "[INFO] Excecuting script: %s\n" ${execscript}
  setarch ${distro_arch} ${execscript} ${chroot_dir}
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

function task_mkrootfs() {
  mkrootfs ${distro_dir}
}

function task_mkdisk() {
  is_dev ${raw} && {
    rmmbr ${raw}
  } || {
    [[ -f ${raw} ]] && rmdisk ${raw}
    printf "[INFO] Creating disk image: \"%s\" of size: %dMB\n" ${raw} ${totalsize}
    mkdisk  ${raw} ${totalsize}
  }
}

function task_mkptab() {
  mkptab  ${raw}
}

function task_mapptab() {
  is_dev ${raw} || {
    printf "[INFO] Creating loop devices corresponding to the created partitions\n"
    mapptab ${raw}
  }
}

function task_mkfs() {
  mkfs2vm ${raw}
}

function task_mount() {
  mountvm ${raw} ${chroot_dir_path}
}

function task_install() {
  installos ${distro_dir} ${raw}
}

function task_postinstall() {
  run_execscript ${chroot_dir_path}
}

function task_umount() {
  umountvm ${chroot_dir_path}
}

function task_unmapptab() {
  is_dev ${raw} || {
    printf "[INFO] Deleting loop devices\n"
    unmapptab_r ${raw}
  }
}

function task_finish() {
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
  losetup -a
  dmsetup ls
}

function task_trap() {
  [[ -d ${chroot_dir_path} ]] && umountvm ${chroot_dir_path} || :
  is_dev ${raw} || {
    unmapptab_r ${raw}
  }
}

### read-only variables

readonly abs_dirname=$(cd $(dirname $0) && pwd)

### include files

. ${abs_dirname}/functions.utils
. ${abs_dirname}/functions.disk
. ${abs_dirname}/functions.mbr

### prepare

extract_args $*

## main

build_vers
checkroot
cmd="$(echo ${CMD_ARGS} | sed "s, ,\n,g" | head -1)"

trap 'exit 1'  HUP INT PIPE QUIT TERM
trap task_trap EXIT

case "${cmd}" in
debug|dump)
  dump_vers
  ;;
rootfs)
  task_mkrootfs
  ;;
prep|prepare)
  task_mkdisk
  ;;
setup)
  task_mkptab
  task_mapptab
  ;;
build)
  task_mkfs
  ;;
install)
  task_mount
  task_install
  task_postinstall
  task_umount
  ;;
post|postinstall)
  task_unmapptab
  task_finish
  ;;
clean)
  task_clean
  ;;
status)
  task_status
  ;;
test::execscript)
  task_mapptab
  task_mount
  task_postinstall
  task_umount
  task_unmapptab
  ;;
soft-test)
  task_mkdisk
  task_mkptab
  task_mapptab
  task_mkfs
  task_unmapptab
  task_finish
  task_clean
  ;;
*)
  # %rootfs
  task_mkrootfs
  # %prep
  task_mkdisk
  # %setup
  task_mkptab
  task_mapptab
  # %build
  task_mkfs
  # %install
  task_mount
  task_install
  task_postinstall
  task_umount
  # %post
  task_unmapptab
  task_finish
  ;;
esac
