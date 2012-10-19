#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare raw=${disk_filename}

## public functions

function tearDown() {
  rm -rf ${chroot_dir}
  rm -f ${disk_filename}
}

function test_create_vm_no_options() {
  create_vm ${disk_filename} ${chroot_dir}
  assertEquals $? 0
}

function test_create_vm_xpart_multiple_partitions() {
  local xpart=${abs_dirname}/../../../xpart.txt.example

  create_vm ${disk_filename} ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
