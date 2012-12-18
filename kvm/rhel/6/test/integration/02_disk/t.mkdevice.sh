#!/bin/bash
#
# requires:
#  bash
#  cd, dirname
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdir ${chroot_dir}
}

function tearDown() {
  ls -lR ${chroot_dir}
  rm -rf ${chroot_dir}
}

function test_mkdevice() {
  mkdevice ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
