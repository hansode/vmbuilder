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
  function run_yum() { echo run_yum $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_install_extras() {
  install_extras ${chroot_dir} | egrep -q openssh
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
