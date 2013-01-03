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
  mkdir -p ${chroot_dir}/sys
}

function tearDown() {
  umount ${chroot_dir}/sys
  rm -rf ${chroot_dir}
}

function test_mount_sys() {
  mount_sys ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
