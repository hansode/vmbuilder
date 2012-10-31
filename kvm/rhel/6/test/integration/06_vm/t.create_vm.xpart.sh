#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

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
