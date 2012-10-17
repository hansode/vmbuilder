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
  add_option_distro
  function run_yum() { echo run_yum $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_bootstrap() {
  bootstrap ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
