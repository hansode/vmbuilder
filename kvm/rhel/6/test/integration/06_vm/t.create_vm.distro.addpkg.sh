#!/bin/bash
#
# requires:
#   bash
#   ssh-keygen
#

## include files

. ./helper_shunit2.sh

### variables

declare pubkey_file=${abs_dirname}/pubkey.$$

### functions

function test_create_vm_distro_addpkg() {
  local addpkg="kpartx parted"

  (
    set -e
    create_vm ${disk_filename} ${chroot_dir}
  )
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
