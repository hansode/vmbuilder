#!/bin/bash
#
# <based on vmbuilder>
#
# NAME
#        vmbuilder - builds virtual machines from the command line
#
# SYNOPSIS
#        vmbuilder <hypervisor> <distro> [OPTIONS]...
#
#        <hypervisor>  Hypervisor image format. Valid options: xen kvm vmw6 vmserver
#
#        <distro>      Distribution. Valid options: ubuntu
#
# OPTIONS
#
#    Guest partitioning options
#
#        The following three options are not used if --part is specified:
#
#               --rootsize SIZE
#                      Size (in MB) of the root filesystem [default: 4096].  Discarded when --part is used.
#
#               --optsize SIZE
#                      Size (in MB) of the /opt filesystem. If not set, no /opt filesystem will be added. Discarded when --part is used.
#
#               --swapsize SIZE
#                      Size (in MB) of the swap partition [default: 1024]. Discarded when --part is used.
#
#   Network related options:
#       --domain DOMAIN
#              Set DOMAIN as the domain name of the guest. Default: The domain of the machine running this script.
#
#       --ip ADDRESS
#              IP address in dotted form [default: dhcp]
#
#       Options below are discarded if --ip is not specified
#              --mask VALUE IP mask in dotted form [default: based on ip setting].
#
#              --net ADDRESS
#                     IP net address in dotted form [default: based on ip setting].
#
#              --bcast VALUE
#                     IP broadcast in dotted form [default: based on ip setting].
#
#              --gw ADDRESS
#                     Gateway (router) address in dotted form [default: based on ip setting (first valid address in the network)].
#
#              --dns ADDRESS
#                     DNS address in dotted form [default: based on ip setting (first valid address in the network)]
#
#    Post install actions:
#        --copy FILE
#               Read 'source dest' lines from FILE, copying source files from host to dest in the guest's file system.
#
#        --execscript SCRIPT, --exec SCRIPT
#               Run SCRIPT after distro installation finishes. Script will be called with the guest's chroot as first argument, so you can use chroot $1 <cmd> to  run  code  in
#               the virtual machine.
#
#
# <based on tune2fs>
#
#       -c max-mount-counts
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
#       -i  interval-between-checks[d|m|w]
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
	optsize="${optsize}"
	swapsize="${swapsize}"
	execscript="${execscript}"
	raw="${raw}"
	ip="${ip}"
	mask="${mask}"
	bcast="${bcast}"
	gw="${gw}"
	dns="${dns}"
	hostname="${hostname}"
	# internal variables
	basearch="${basearch}"
	disk_filename="${disk_filename}"
	# required commands
	build_rootfs_tree_sh="${build_rootfs_tree_sh}"
	cat="${cat}"
	truncate="${truncate}"
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
  i*86)   basearch=i386; distro_arch=i686;;
  x86_64) basearch=${distro_arch};;
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

  [[ -n ${dry_run} ]] && {
    build_rootfs_tree_sh="echo ${abs_path}/build-rootfs-tree.sh"
    cat="echo ${cat}"
    truncate="echo ${truncate}"
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
  } || :

  # * tune2fs
  # > This filesystem will be automatically checked every 37 mounts or
  # > 180 days, whichever comes first.  Use tune2fs -c or -i to override.
  max_mount_count=${max_mount_count:-37}
  interval_between_check=${interval_between_check:-180}

  # * /usr/share/pyshared/VMBuilder/contrib/cli.py
  rootsize=${rootsize:-4096}
  optsize=${optsize:-0}
  swapsize=${swapsize:-1024}
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

  # local params
  disk_filename=${raw}
}

function mkrootfs() {
  local distro_dir=$1
  [[ -d "${distro_dir}" ]] || {
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

function mkdisk() {
  local disk_filename=$1
  [[ -a ${disk_filename} ]] && { echo "already exists: ${disk_filename}" >&2; return 1; }
  local size=$((${rootsize} + ${optsize} + ${swapsize}))
  printf "[INFO] Creating disk image: \"%s\" of size: %dMB\n" ${disk_filename} ${size}
  ${truncate} -s ${size}M ${disk_filename}
}

function rmdisk() {
  local disk_filename=$1
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  ${rm} -f ${disk_filename}
}

function mkptab() {
  local disk_filename=$1
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }

  printf "[INFO] Adding partition table to disk image: %s\n" ${disk_filename}
  ${parted} --script ${disk_filename} mklabel msdos

  local offset=0

  # root
  printf "[INFO] Adding type %s partition to disk image: %s\n" ext2 ${disk_filename}
  ${parted} --script -- ${disk_filename} mkpart  primary ext2 ${offset} $((${rootsize} - 1))
  offset=$((${offset} + ${rootsize}))
  # swap
  [[ ${swapsize} -gt 0 ]] && {
    printf "[INFO] Adding type %s partition to disk image: %s\n" swap ${disk_filename}
    ${parted} --script -- ${disk_filename} mkpart  primary 'linux-swap(new)' ${offset} $((${offset} + ${swapsize} - 1))
    offset=$((${offset} + ${swapsize}))
  } || :
  # opt
  [[ ${optsize} -gt 0 ]] && {
    printf "[INFO] Adding type %s partition to disk image: %s\n" ext2 ${disk_filename}
    ${parted} --script -- ${disk_filename} mkpart  primary ext2 ${offset} $((${offset} + ${optsize} - 1))
  } || :
}

function mapptab() {
  local disk_filename=$1
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  printf "[INFO] Creating loop devices corresponding to the created partitions\n"
  ${kpartx} -vsa ${disk_filename} && ${udevadm} settle
  # add map loop0p1 (253:3): 0 1998013 linear /dev/loop0 34
}

function unmapptab() {
  local disk_filename=$1
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  ${kpartx} -vsd ${disk_filename}
  # del devmap : loop0p1
}

function unmapptab_r() {
  local disk_filename=$1
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  printf "[INFO] Deleting loop devices\n"
  local tries=0 local max_tries=3
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
    echo /dev/mapper/${devmap}
  done
}

function mkfs2vm() {
  local disk_filename=$1
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  lsdevmap ${disk_filename} | devmap2path | while read part_filename; do
    case ${part_filename} in
    *p1|*p3)
      ${mkfs} -F ${part_filename}

      # > This filesystem will be automatically checked every 37 mounts or
      # > 180 days, whichever comes first.  Use tune2fs -c or -i to override.
      [ ! "${max_mount_count}" -eq 37 -o ! "${interval_between_check}" -eq 180 ] && {
        printf "[INFO] Setting maximal mount count: %s\n" ${max_mount_count}
        printf "[INFO] Setting interval between check(s): %s\n" ${interval_between_check}
        ${tune2fs} -c ${max_mount_count} -i ${interval_between_check} ${part_filename}
      }
      ;;
    *p2)
      ${mkswap} ${part_filename}
      ;;
    *)
      ;;
    esac
    ${udevadm} settle
  done
}

function mountvm() {
  local disk_filename=$1 mntpnt=$2
  [[ -a ${disk_filename} ]] || { echo "file not found: ${disk_filename}" >&2; return 1; }
  [[ -d "${mntpnt}" ]] && { echo "already exists: ${mntpnt}" >&2; return 1; }
  ${mkdir} -p ${mntpnt}
  lsdevmap ${disk_filename} | devmap2path | while read part_filename; do
    case ${part_filename} in
    *p1)
      printf "[DEBUG] Mounting %s\n" ${mntpnt}
      ${mount} ${part_filename} ${mntpnt}
      ;;
    esac
  done
}

function installos() {
  local disk_filename=$1
  [[ -d "${distro_dir}" ]] || { echo "no such directory: ${distro_dir}" >&2; exit 1; }

  local mntpnt=/tmp/tmp$(date +%s)

  mountvm ${disk_filename} ${mntpnt}

  printf "[DEBUG] Installing OS to %s\n" ${mntpnt}
  ${rsync} -aHA ${distro_dir}/ ${mntpnt}
  ${sync}
  printf "[INFO] Setting /etc/yum.conf: keepcache=%s\n" ${keepcache}
  ${sed} -i s,^keepcache=.*,keepcache=${keepcache}, ${mntpnt}/etc/yum.conf

  installgrub2vm       ${mntpnt}
  configure_networking ${mntpnt}
  configure_mounting   ${mntpnt}
  run_execscript       ${mntpnt}

  umountvm             ${mntpnt}
}

function installgrub2vm() {
  local chroot_dir=${mntpnt}
  tmpdir=/tmp/vmbuilder-grub
  ${mkdir} -p ${chroot_dir}/${tmpdir}

  devmapfile=${tmpdir}/device.map
  ${touch} ${chroot_dir}/${devmapfile}
  grub_id=0

  new_filename=${tmpdir}/$(basename ${disk_filename})
  ${touch} ${chroot_dir}/${new_filename}
  ${mount} --bind ${disk_filename} ${chroot_dir}/${new_filename}
  printf "(hd%d) %s\n" ${grub_id} ${new_filename} >> ${chroot_dir}/${devmapfile}
  ${cat} ${chroot_dir}/${devmapfile}

  # install grub
  ${cat} <<-_EOS_ | ${chroot} ${chroot_dir} ${grub} --device-map=${devmapfile} --batch
	root (hd${grub_id},0)
	setup (hd0)
	quit
	_EOS_

  uuids=$(
    lsdevmap ${disk_filename} | devmap2path | while read part_filename; do
      ${blkid} -c /dev/null -sUUID -ovalue ${part_filename}
    done
  )
  rootdev_uuid=$(echo ${uuids} | awk '{print $1}')

  printf "[INFO] Generating /boot/grub/grub.conf.\n"
  ${cat} <<-_EOS_ > ${chroot_dir}/boot/grub/grub.conf
	default=0
	timeout=5
	splashimage=(hd${grub_id},0)/boot/grub/splash.xpm.gz
	hiddenmenu
	title ${distro} ($(cd ${chroot_dir}/boot && ls vmlinuz-* | tail -1 | sed 's,^vmlinuz-,,'))
	        root (hd${grub_id},0)
	        kernel /boot/$(cd ${chroot_dir}/boot && ls vmlinuz-* | tail -1) ro root=UUID=${rootdev_uuid} rd_NO_LUKS rd_NO_LVM LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM
	        initrd /boot/$(cd ${chroot_dir}/boot && ls initramfs-*| tail -1)
	_EOS_
  ${cat} ${chroot_dir}/boot/grub/grub.conf
  ${chroot} ${chroot_dir} ${ln} -s /boot/grub/grub.conf /boot/grub/menu.lst
}

function configure_networking() {
  local chroot_dir=${mntpnt}
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
  local chroot_dir=${mntpnt}
  uuids=$(
    lsdevmap ${disk_filename} | devmap2path | while read part_filename; do
      ${blkid} -c /dev/null -sUUID -ovalue ${part_filename}
    done
  )
  rootdev_uuid=$(echo ${uuids} | awk '{print $1}')
  swapdev_uuid=$(echo ${uuids} | awk '{print $2}')
  optdev_uuid=$(echo ${uuids} | awk '{print $3}')

  printf "[INFO] Overwriting /etc/fstab.\n"
  ${cat} <<-_EOS_ > ${chroot_dir}/etc/fstab
	UUID=${rootdev_uuid} /                       ext4    defaults        1 1
	$([[ ${swapsize} -gt 0 ]] && { ${cat} <<-_SWAPDEV_
	UUID=${swapdev_uuid} swap                    swap    defaults        0 0
	_SWAPDEV_
	})
	$([[ ${optsize} -gt 0 ]] && { ${cat} <<-_OPTDEV_
	UUID=${optdev_uuid} /opt                    ext4    defaults        1 1
	_OPTDEV_
	})
	tmpfs                   /dev/shm                tmpfs   defaults        0 0
	devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
	sysfs                   /sys                    sysfs   defaults        0 0
	proc                    /proc                   proc    defaults        0 0
	_EOS_
  ${cat} ${chroot_dir}/etc/fstab
}

function run_execscript() {
  local chroot_dir=${mntpnt}
  [[ -z "${execscript}" ]] && {
    ${chroot} ${chroot_dir} bash -c "echo root:root | chpasswd"
  } || {
    [[ -f "${execscript}" ]] && {
      [[ -x "${execscript}" ]] && {
        printf "[INFO] Excecuting after script\n"
        ${setarch} ${distro_arch} ${execscript} ${chroot_dir}
      } || :
    } || :
  }
}

function umountvm() {
  local chroot_dir=${mntpnt}
  printf "[DEBUG] Unmounting %s\n" ${chroot_dir}/${new_filename}
  ${umount} ${chroot_dir}/${new_filename}
  printf "[DEBUG] Deleting %s\n" ${chroot_dir}/${tmpdir}
  ${rm} -rf ${chroot_dir}/${tmpdir}

  printf "[DEBUG] Unmounting %s\n" ${mntpnt}
  ${umount} ${mntpnt}
  ${rmdir} ${mntpnt}
}

### prepare

extract_args $*

### read-only variables

readonly abs_path=$(cd $(dirname $0) && pwd)

## main

build_vers

mkrootfs ${distro_dir}

[[ -f ${disk_filename} ]] && rmdisk ${disk_filename}
mkdisk  ${disk_filename}
mkptab  ${disk_filename}
mapptab ${disk_filename}
mkfs2vm ${disk_filename}

installos ${disk_filename}

unmapptab_r ${disk_filename}

printf "[INFO] Generated => %s\n" ${disk_filename}
printf "[INFO] Complete!\n"
