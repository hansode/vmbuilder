#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare devel_user=shunit$$
declare pubkey_file=${abs_dirname}/pubkey_file.$$

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/home/${devel_user}

  date > ${pubkey_file}
}

function tearDown() {
  rm -f  ${pubkey_file}
  rm -rf ${chroot_dir}
}

function test_add_authorized_keys_no_opts() {
  add_authorized_keys 2>/dev/null
  assertNotEquals $? 0
}

function test_add_authorized_keys_opts_userdir() {
  add_authorized_keys ${chroot_dir}/home/${devel_user} 2>/dev/null
  assertNotEquals $? 0
}

function test_add_authorized_keys_opts_userdir_keyfile() {
  add_authorized_keys ${chroot_dir}/home/${devel_user} ${pubkey_file} >/dev/null
  assertEquals $? 0

  [[ -f  ${chroot_dir}/home/${devel_user}/.ssh/authorized_keys ]]
  assertEquals $? 0
}

function test_add_authorized_keys_opts_file_exists() {
  mkdir   ${chroot_dir}/home/${devel_user}/.ssh
  date >> ${chroot_dir}/home/${devel_user}/.ssh/authorized_keys
  :    >> ${chroot_dir}/home/${devel_user}/.ssh/authorized_keys
  date >> ${chroot_dir}/home/${devel_user}/.ssh/authorized_keys

  local before="$(cat ${chroot_dir}/home/${devel_user}/.ssh/authorized_keys)"

  add_authorized_keys ${chroot_dir}/home/${devel_user} ${pubkey_file} >/dev/null
  assertEquals $? 0

  local after="$(cat ${chroot_dir}/home/${devel_user}/.ssh/authorized_keys)"
  diff <(echo "${before}";  cat ${pubkey_file}) <(echo "${after}")
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
