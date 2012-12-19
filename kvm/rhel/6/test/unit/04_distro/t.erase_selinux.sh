#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdir -p ${chroot_dir}

  function run_yum() { echo run_yum $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_erase_selinux() {
  erase_selinux ${chroot_dir} | egrep erase | egrep -q selinux
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
