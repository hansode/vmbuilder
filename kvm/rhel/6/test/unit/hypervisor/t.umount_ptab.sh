#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdisk ${disk_filename} ${totalsize}
  mkptab ${disk_filename}
  mapptab ${disk_filename}
  mkfsdisk ${disk_filename}
  mkdir -p ${chroot_dir}
  mount_ptab ${disk_filename} ${chroot_dir}
}

function tearDown() {
  rm -f ${disk_filename}
  rm -rf ${chroot_dir}
}

function test_umount_ptab() {
  umount_ptab ${chroot_dir}
  unmapptab ${disk_filename}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
