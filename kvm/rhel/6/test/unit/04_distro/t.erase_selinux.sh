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

function test_erase_selinux() {
  erase_selinux ${chroot_dir} | egrep erase | egrep -q selinux
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
