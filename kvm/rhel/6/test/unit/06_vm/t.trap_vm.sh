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
  mkdir -p ${chroot_dir}

  mkdisk ${disk_filename} $(sum_disksize) 2>/dev/null
  mkptab ${disk_filename}
  mapptab ${disk_filename}
  mkfsdisk ${disk_filename} ext4
  mount_ptab ${disk_filename} ${chroot_dir}
}

function tearDown() {
  rm -f ${disk_filename}
  rm -rf ${chroot_dir}
}

function test_trap_vm() {
  trap_vm ${disk_filename} ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
