#!/bin/bash
#
# description:
#  VM builder
#
# requires:
#  bash
#  tr, dirname, pwd
#  sed, head
#  printf, awk, rm
#
# import:
#  vm: create_vm
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
}

### read-only variables

readonly abs_dirname=$(cd $(dirname $0) && pwd)

### include files

. ${abs_dirname}/functions.utils
. ${abs_dirname}/functions.disk
. ${abs_dirname}/functions.mbr
. ${abs_dirname}/functions.distro
. ${abs_dirname}/functions.hypervisor
. ${abs_dirname}/functions.vm

### prepare

extract_args $*

## main

register_options
cmd="$(echo ${CMD_ARGS} | sed "s, ,\n,g" | head -1)"

case "${cmd}" in
*)
  create_vm
  ;;
esac
