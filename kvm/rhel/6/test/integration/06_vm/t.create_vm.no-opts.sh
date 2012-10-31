#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

###

function test_create_vm_no_options() {
  (
   set -e
   create_vm ${disk_filename} ${chroot_dir}
  )
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
