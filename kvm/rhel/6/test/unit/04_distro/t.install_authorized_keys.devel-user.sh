#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare pubkey_file=${abs_dirname}/pubkey_file.$$

declare devel_user=vmbuilder

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/home/${devel_user}

  date > ${pubkey_file}
  function run_in_target() { echo run_in_target $*; }
}

function tearDown() {
  rm -f  ${pubkey_file}
  rm -rf ${chroot_dir}
}

function test_install_authorized_keys_ssh_user_key_empty() {
  local ssh_user_key=
  install_authorized_keys ${chroot_dir}
}

function test_install_authorized_keys_ssh_user_key() {
  local ssh_user_key=${pubkey_file}
  install_authorized_keys ${chroot_dir} >/dev/null

  [[ -d ${chroot_dir}/home/${devel_user}/.ssh ]]
  assertEquals $? 0

  [[ -f ${chroot_dir}/home/${devel_user}/.ssh/authorized_keys ]]
  assertEquals $? 0

  diff ${pubkey_file} ${chroot_dir}/home/${devel_user}/.ssh/authorized_keys
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
