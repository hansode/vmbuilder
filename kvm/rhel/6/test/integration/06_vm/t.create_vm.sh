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

###

function test_create_vm_no_options() {
  (
   set -e
   create_vm ${disk_filename} ${chroot_dir}
  )
  assertEquals $? 0
}

### *size options

function test_create_vm_minimal_root_swap_opt_home_usr_var_tmp() {
  local rootsize=256 swapsize=4 optsize=4 bootsize=64 homesize=4 usrsize=384 varsize=128 tmpsize=48

  (
    set -e
    create_vm ${disk_filename} ${chroot_dir}
  )
  assertEquals $? 0
}

### root

function test_create_vm_minimal_root() {
  local rootsize=700

  (
    set -e
    create_vm ${disk_filename} ${chroot_dir}
  )
  assertEquals $? 0
}

function test_create_vm_not_enough_root() {
  local rootsize=650

  (
    set -e
    create_vm ${disk_filename} ${chroot_dir}
  )
  assertNotEquals $? 0
}

### /tmp

function test_create_vm_not_enough_tmp() {
  local rootsize=700 tmpsize=45

  (
    set -e
    create_vm ${disk_filename} ${chroot_dir}
  )
  assertNotEquals $? 0
}

function test_create_vm_minimal_tmp() {
  local rootsize=700 tmpsize=46

  (
    set -e
    create_vm ${disk_filename} ${chroot_dir}
  )
  assertEquals $? 0
}

### xpart

function test_create_vm_xpart() {
  local xpart=${abs_dirname}/../../../xpart.txt.example

  (
    set -e
    create_vm ${disk_filename} ${chroot_dir}
  )
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
