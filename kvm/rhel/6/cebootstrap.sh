#!/bin/bash
#
# requires:
#  bash
#  tr, dirname, pwd
#  sed, head
#  cat, mkdir, rm, printf
#
# OPTIONS
#        --distro-arch=[x86_64 | i686]
#        --distro-name=[centos | sl]
#        --distro-ver=[6 | 6.0 | 6.2 | ... ]
#        --chroot-dir=/path/to/rootfs
#        --keepcache=1
#        --debug=1
#
set -e

## private functions

function register_options() {
  debug=${debug:-}
  [ -z ${debug} ] || set -x
  preflight_check_distro
  chroot_dir=${chroot_dir:-${abs_dirname}/${distro_short}-${distro_ver}_${distro_arch}}
}

### read-only variables

readonly abs_dirname=$(cd $(dirname $0) && pwd)

### include files

. ${abs_dirname}/functions.utils
. ${abs_dirname}/functions.disk
. ${abs_dirname}/functions.distro

### prepare

extract_args $*

## main

register_options
checkroot
cmd="$(echo ${CMD_ARGS} | sed "s, ,\n,g" | head -1)"

trap "trap_distro ${chroot_dir}" 1 2 3 15

case "${cmd}" in
*)
  build_chroot ${chroot_dir}
  ;;
esac
