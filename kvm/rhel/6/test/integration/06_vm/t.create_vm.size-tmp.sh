#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

### /tmp

function test_create_vm_not_enough_tmp() {
  local rootsize=700 tmpsize=45

  (
    set -e
    create_vm ${disk_filename} ${chroot_dir}
  )
  assertNotEquals $? 0
}

function _test_create_vm_minimal_tmp() {
  local rootsize=700 tmpsize=46

  (
    set -e
    create_vm ${disk_filename} ${chroot_dir}
  )
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
