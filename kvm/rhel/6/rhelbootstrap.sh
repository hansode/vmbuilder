#!/bin/bash
#
# description:
#  Bootstrap a basic RHEL system
#
# requires:
#  bash
#  pwd
#
# import:
#   distro: build_chroot
#
# OPTIONS
#        --distro-arch=[x86_64 | i686]
#        --distro-name=[rhel]
#        --distro-ver=[7 | 7.0 | ... ]
#        --chroot-dir=/path/to/rootfs
#        --keepcache=1
#        --debug=1
#
set -e

## private functions

function register_options() {
  debug=${debug:-}
  [[ -z "${debug}" ]] || set -x
  chroot_dir=${chroot_dir:-}

  distro_name=rhel
  distro_ver=${distro_ver:-7}
}

### environment variables

export LANG=C
export LC_ALL=C

### read-only variables

readonly abs_dirname=$(cd ${BASH_SOURCE[0]%/*} && pwd)

### include files

. ${abs_dirname}/functions/utils.sh
. ${abs_dirname}/functions/disk.sh
. ${abs_dirname}/functions/distro.sh

### prepare

extract_args $*

## main

[[ -f "${config_path}" ]] && load_config ${config_path} || :
register_options
build_chroot ${chroot_dir}
