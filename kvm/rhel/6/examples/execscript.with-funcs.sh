#!/bin/bash
#
# requires:
#  bash
#  tr
#
# imports:
#  distro: detect_distro, create_initial_user
#
set -x
set -e

### read-only variables

readonly abs_dirname=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

### private variables

declare chroot_dir=$1

### include files

. ${abs_dirname}/../functions/utils.sh
. ${abs_dirname}/../functions/distro.sh

### main

echo "doing execscript.sh: $1"
eval $(detect_distro ${chroot_dir})
devel_user=$(echo ${DISTRIB_ID} | tr A-Z a-z)

# 1. reupdate root password
# 2. add ${devel_user} as a new unix user

create_initial_user ${chroot_dir}
