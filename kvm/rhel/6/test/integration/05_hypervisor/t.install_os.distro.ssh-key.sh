#!/bin/bash
#
# requires:
#   bash
#   ssh-keygen
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

### variables

declare pubkey_file=${abs_dirname}/pubkey.$$

### functions

function additional_setUp() {
  ssh-keygen -N "" -f ${pubkey_file}
}

function additional_tearDown() {
  rm -f ${pubkey_file}
  rm -f ${pubkey_file}.pub
}

function test_install_os_distro_ssh_key() {
  local ssh_key=${pubkey_file}

  (
    set -e
    install_os ${chroot_dir} ${distro_dir} ${disk_filename}
  )
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
