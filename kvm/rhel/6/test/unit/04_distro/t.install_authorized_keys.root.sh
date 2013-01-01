#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

declare pubkey_file=${abs_dirname}/pubkey_file.$$

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/root

  date > ${pubkey_file}
}

function tearDown() {
  rm -f  ${pubkey_file}
  rm -rf ${chroot_dir}
}

function test_install_authorized_keys_ssh_key_empty() {
  local ssh_key=
  install_authorized_keys ${chroot_dir}

  [[ -f ${chroot_dir}/root/.ssh/authorized_keys ]]
  assertNotEquals $? 0
}

function test_install_authorized_keys_ssh_key_defined() {
  local ssh_key=${pubkey_file}
  install_authorized_keys ${chroot_dir} >/dev/null

  [[ -d ${chroot_dir}/root/.ssh ]]
  assertEquals $? 0

  [[ -f ${chroot_dir}/root/.ssh/authorized_keys ]]
  assertEquals $? 0

  diff ${pubkey_file} ${chroot_dir}/root/.ssh/authorized_keys
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
