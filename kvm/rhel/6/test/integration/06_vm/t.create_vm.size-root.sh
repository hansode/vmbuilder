#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

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

## shunit2

. ${shunit2_file}
