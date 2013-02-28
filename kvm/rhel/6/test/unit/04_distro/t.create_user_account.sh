#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare username=vmbuilder

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc
  mkdir -p ${chroot_dir}/home/${username}
  touch    ${chroot_dir}/home/${username}/.bashrc

  function chroot() { echo chroot $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_create_user_account_no_opts() {
  create_user_account ${chroot_dir} 2>/dev/null
  assertNotEquals $? 0
}

function test_create_user_account() {
  create_user_account ${chroot_dir} ${username} >/dev/null
  assertEquals $? 0
}

function test_create_user_account_getent_group() {
  create_user_account ${chroot_dir} ${username} | egrep -q -w "getent group ${username}"
  assertEquals $? 0
}

function test_create_user_account_getent_passwd() {
  create_user_account ${chroot_dir} ${username} | egrep -q -w "getent passwd ${username}"
  assertEquals $? 0
}

function test_create_user_account_umask() {
  create_user_account ${chroot_dir} ${username} >/dev/null

  egrep -q -w "^umask 022" ${chroot_dir}/home/${username}/.bashrc
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
