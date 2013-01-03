#!/bin/bash
#
# requires:
#  bash
#  cd
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/proc
  mkdir -p ${chroot_dir}/dev
  checkroot || return 1
  mount --bind /proc ${chroot_dir}/proc
  mount --bind /dev  ${chroot_dir}/dev
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_umount_nonroot() {
  umount_nonroot ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
