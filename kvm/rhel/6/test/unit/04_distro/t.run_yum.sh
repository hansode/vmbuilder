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
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_run_yum_distro_name_empty() {
  run_yum ${chroot_dir} help >/dev/null
  assertNotEquals $? 0
}

function test_run_yum_distro_name_exists() {
  add_option_distro

  run_yum ${chroot_dir} help >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
