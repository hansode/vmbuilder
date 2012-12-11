#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

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
  create_initial_user ${chroot_dir}
  assertEquals $? 0
}

function test_create_initial_user_no_opts() {
  create_initial_user
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
