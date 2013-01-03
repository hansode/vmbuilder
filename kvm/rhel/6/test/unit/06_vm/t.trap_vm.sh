#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  touch ${disk_filename}

  function checkroot() { :; }

  function is_dev() { return 1; }
  function unmapptab() { echo unmapptab $*; }
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_trap_vm() {
  trap_vm ${disk_filename} ${chroot_dir} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
