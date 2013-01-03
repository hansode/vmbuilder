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
  mkdir ${chroot_dir}
  checkroot || return 1
  mount --bind /proc ${chroot_dir}
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_umount_root() {
  umount_root ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
