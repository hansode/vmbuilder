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
  mkdisk ${disk_filename} $(sum_disksize)
  mkptab ${disk_filename}
  mapptab ${disk_filename}
  mkfsdisk ${disk_filename} ext4
  mkdir -p ${chroot_dir}
}

function tearDown() {
  umount_ptab ${chroot_dir}
  unmapptab ${disk_filename}
  rm -f ${disk_filename}
  rm -rf ${chroot_dir}
}

function test_mount_ptab() {
  mount_ptab ${disk_filename} ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
