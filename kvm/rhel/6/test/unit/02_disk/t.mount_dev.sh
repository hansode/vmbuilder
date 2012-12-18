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
  mkdir -p ${chroot_dir}/dev

  function checkroot() { :; }
  function mount() { :; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_mount_dev() {
  mount_dev ${chroot_dir} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
