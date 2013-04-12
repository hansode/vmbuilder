#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare username=vmbuilder
declare encpassword=$6$7abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrst

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc
  mkdir -p ${chroot_dir}/home/${username}

  function chroot() { echo chroot $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_update_user_encpassword_no_opts() {
  update_user_encpassword ${chroot_dir} 2>/dev/null
  assertNotEquals $? 0
}

function test_update_user_encpassword_user() {
  update_user_encpassword ${chroot_dir} ${username} 2>/dev/null
  assertNotEquals $? 0
}

function test_update_user_encpassword_user_encpass() {
  update_user_encpassword ${chroot_dir} ${username} ${encpassword} | egrep -q -w "echo ${username}:${encpassword} | chpasswd -e"
  update_user_encpassword ${chroot_dir} ${username} ${encpassword} | egrep -q -w "echo ${username}:${encpassword} | chpasswd -e"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
