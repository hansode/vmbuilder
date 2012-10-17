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
  add_option_distro
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_run_yum() {
  run_yum ${chroot_dir} help >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
