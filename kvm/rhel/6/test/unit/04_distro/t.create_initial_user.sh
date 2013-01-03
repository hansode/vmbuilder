#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdir -p ${chroot_dir}

  function chroot() { echo chroot $*; }
  function update_passwords() { echo update_passwords $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_create_initial_user() {
  create_initial_user ${chroot_dir} >/dev/null
  assertEquals $? 0
}

function test_create_initial_user_no_opts() {
  create_initial_user 2>/dev/null
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
