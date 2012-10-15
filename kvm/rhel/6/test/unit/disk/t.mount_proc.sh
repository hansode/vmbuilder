#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare chroot_dir=_chroot.$$

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/proc
}

function tearDown() {
  umount ${chroot_dir}/proc
  rm -rf ${chroot_dir}
}

function test_mount_proc() {
  mount_proc ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
