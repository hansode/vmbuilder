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

function setUp() {
  ssh-keygen -N "" -f ${pubkey_file}
}

function additional_tearDown() {
  rm -f ${pubkey_file}
  rm -f ${pubkey_file}.pub
}

function test_create_vm_distro_ssh_user_key() {
  local devel_user=vmbuilder
  local ssh_user_key=${pubkey_file}

  (
    set -e
    create_vm ${disk_filename} ${chroot_dir}
  )
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
