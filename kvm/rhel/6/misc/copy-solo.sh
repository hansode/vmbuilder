#!/bin/bash
#
# description:
#  copy solo
#
# requires:
#  bash
#  pwd
#
# import:
#  utils: extract_args
#  distro: run_copies
#
# usage:
#  $ copy-solo.sh [copy.txt] [copy.txt] ...
#
set -e

## private functions

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

chroot_dir=${chroot_dir:-/}
run_copies ${chroot_dir} ${CMD_ARGS}
