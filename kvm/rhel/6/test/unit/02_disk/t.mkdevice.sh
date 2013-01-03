#!/bin/bash
#
# requires:
#  bash
#  cd
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdir ${chroot_dir}

  function checkroot() { :; }
  function mkdir() { echo mkdir $*; }
  function mknod() { echo mknod $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_mkdevice() {
  mkdevice ${chroot_dir} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
