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
  mkdir -p ${chroot_dir}/etc
  function chroot() { echo chroot $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_fstab() {
  reconfigure_fstab ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
