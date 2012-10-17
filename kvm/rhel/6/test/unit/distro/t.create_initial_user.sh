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
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_create_initial_user() {
  create_initial_user ${chroot_dir} | egrep -q "^chroot ${chroot_dir} bash -c echo root:root | chpasswd"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
