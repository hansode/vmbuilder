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

function test_create_vm_xpart_multiple_partitions_root_swap_opt_home_usr_var() {
  local rootsize=256 swapsize=4 optsize=4 bootsize=64 homesize=4 usrsize=384 varsize=128

  create_vm ${disk_filename} ${chroot_dir}
  assertEquals $? 0
}

function test_create_vm_xpart_multiple_partitions_xpart() {
  local xpart=${abs_dirname}/../../../xpart.txt.example

  create_vm ${disk_filename} ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
