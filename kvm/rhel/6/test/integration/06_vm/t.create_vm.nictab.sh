#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

### nictab

function test_create_vm_nictab() {
  local nictab=${abs_dirname}/../../../nictab.txt.example

  (
    set -e
    create_vm ${disk_filename} ${chroot_dir}
  )
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
