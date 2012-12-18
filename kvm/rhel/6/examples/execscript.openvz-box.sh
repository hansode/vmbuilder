#!/bin/bash
#
# usage:
#  $ vmbuilder --execscript=./examples/execscript.openvz-box.sh
#
# requires:
#  bash
#
# imports:
#  utils:
#  distro: configure_openvz
#
set -x
set -e

### read-only variables

readonly abs_dirname=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

### include files

. ${abs_dirname}/../functions/utils.sh
. ${abs_dirname}/../functions/distro.sh

### private variables

declare chroot_dir=$1

### main

echo "doing execscript.sh: ${chroot_dir}"

#### openvz

configure_openvz ${chroot_dir}
