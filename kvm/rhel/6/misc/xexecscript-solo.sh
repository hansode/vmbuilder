#!/bin/bash
#
# description:
#  xexecscripts solo
#
# requires:
#  bash
#  pwd
#
# import:
#  utils: extract_args
#  distro: run_xexecscripts
#
# usage:
#  $ xexecscript-solo.sh [xexecscript] [xexecscript] ...
#
set -e

## private functions

function register_options() {
  debug=${debug:-}
  [[ -z "${debug}" ]] || set -x
  config_path=${config_path:-}

  distro_name=${distro_name:-centos}
  distro_ver=${distro_ver:-6}
  hypervisor=${hypervisor:-kvm}
}

### read-only variables

readonly abs_dirname=$(cd ${BASH_SOURCE[0]%/*} && pwd)

### include files

. ${abs_dirname}/../functions/utils.sh
. ${abs_dirname}/../functions/disk.sh
. ${abs_dirname}/../functions/mbr.sh
. ${abs_dirname}/../functions/distro.sh
. ${abs_dirname}/../functions/hypervisor.sh
. ${abs_dirname}/../functions/vm.sh

### prepare

extract_args $*

[[ -f "${config_path}" ]] && load_config ${config_path} || :
register_options

declare chroot_dir=/
run_xexecscripts ${chroot_dir} ${CMD_ARGS}
