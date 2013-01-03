#!/bin/bash
#
# description:
#  execscript for vmbuilder.sh
#
# usage:
#  $ vmbuilder.sh --execscript=./examples/dev-vmbox/execscript.sh
#
# requires:
#  bash
#  cat, tee, chroot
#
# imports:
#  utils: run_in_target
#  distro: configure_openvz, detect_distro, create_initial_user
#
set -x
set -e

### read-only variables

readonly abs_dirname=$(cd ${BASH_SOURCE[0]%/*} && pwd)

### include files

. ${abs_dirname}/../../functions/utils.sh
. ${abs_dirname}/../../functions/distro.sh

### private variables

declare chroot_dir=$1

### main

echo "doing execscript.sh: ${chroot_dir}"

#### openvz

configure_openvz ${chroot_dir}

#### unix account

eval $(detect_distro ${chroot_dir})
devel_user=$(echo ${DISTRIB_ID} | tr A-Z a-z)

# 1. reupdate root password
# 2. add ${devel_user} as a new unix user

create_initial_user ${chroot_dir}

#### additional packages

run_in_target ${chroot_dir} \
 yum install -y \
  git make curl vim-minimal screen \
  ntp ntpdate bridge-utils  \
  kpartx parted \
  qemu-img qemu-kvm
