#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare username=vmbuilder
declare password=vmbuilder

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc
  mkdir -p ${chroot_dir}/home/${username}

  function chroot() { echo chroot $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_update_user_password_no_opts() {
  update_user_password ${chroot_dir} 2>/dev/null
  assertNotEquals $? 0
}

function test_update_user_password_user() {
  update_user_password ${chroot_dir} ${username} 2>/dev/null
  assertNotEquals $? 0
}

function test_update_user_password_user_pass() {
  update_user_password ${chroot_dir} ${username} ${password} | egrep -q -w "echo ${username}:${password} | chpasswd"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
