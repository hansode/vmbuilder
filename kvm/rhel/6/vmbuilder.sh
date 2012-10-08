#!/bin/bash
#
# requires:
#  bash
#  tr, dirname, pwd
#  sed, head
#  cat
#  printf, setarch
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

function register_options() {
  debug=${debug:-}
  [[ -z "${debug}" ]] || set -x

  distro_arch=${distro_arch:-$(arch)}
  case "${distro_arch}" in
  i*86)   basearch=i386; distro_arch=i686 ;;
  x86_64) basearch=${distro_arch} ;;
  esac

  distro_ver=${distro_ver:-6.3}
  distro_name=${distro_name:-centos}

  keepcache=${keepcache:-0}
  case "${keepcache}" in
  [01]) ;;
  *)    keepcache=0 ;;
  esac

  distro=${distro_name}-${distro_ver}_${distro_arch}
  distro_dir=${distro_dir:-${abs_dirname}/${distro}}

  max_mount_count=${max_mount_count:-37}
  interval_between_check=${interval_between_check:-180}

  rootsize=${rootsize:-4096}
  bootsize=${bootsize:-0}
  optsize=${optsize:-0}
  swapsize=${swapsize:-1024}
  homesize=${homesize:-0}

  xpart=${xpart:-}
  execscript=${execscript:-}
  raw=${raw:-./${distro}.raw}

  chroot_dir=${chroot_dir:-/tmp/tmp$(date +%s)}

  #domain=${domain:-}
  ip=${ip:-}
  mask=${mask:-}
  net=${net:-}
  bcast=${bcast:-}
  gw=${gw:-}
  dns=${dns:-}
  hostname=${hostname:-}
}

## vmdisk

function run_execscript() {
  local chroot_dir=$1 execscript=$2
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  [[ -f "${execscript}" ]] || return 0
  [[ -x "${execscript}" ]] || return 0
  mount_proc ${chroot_dir}
  mount_dev  ${chroot_dir}
  printf "[INFO] Excecuting script: %s\n" ${execscript}
  setarch ${distro_arch} ${execscript} ${chroot_dir}
}

## task

function task_bootstrap() {
  bootstrap ${distro_dir}
}

function task_mkdisk() {
  is_dev ${raw} && {
    rmmbr ${raw}
  } || {
    [[ -f ${raw} ]] && rmdisk ${raw}
    local totalsize=$((${rootsize} + ${optsize} + ${swapsize} + ${homesize}))
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
  mkfs ${raw}
}

function task_mount() {
  mount_ptab ${raw} ${chroot_dir}
}

function task_install() {
  install_os ${chroot_dir} ${distro_dir} ${raw} ${keepcache}
}

function task_postinstall() {
  run_execscript ${chroot_dir} ${execscript}
}

function task_umount() {
  umount_ptab ${chroot_dir}
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
}

function task_status() {
  losetup -a
  dmsetup ls
}

function task_trap() {
  [[ -d ${chroot_dir} ]] && umount_ptab ${chroot_dir} || :
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
. ${abs_dirname}/functions.distro
. ${abs_dirname}/functions.hypervisor

### prepare

extract_args $*

## main

register_options
checkroot
cmd="$(echo ${CMD_ARGS} | sed "s, ,\n,g" | head -1)"

trap 'exit 1'  HUP INT PIPE QUIT TERM
trap task_trap EXIT

case "${cmd}" in
bootstrap)
  task_bootstrap
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
  # %bootstrap
  task_bootstrap
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
