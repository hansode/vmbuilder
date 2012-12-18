#!/bin/bash
#
# requires:
#  bash
#  cd, dirname
#  touch, rm
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  touch ${disk_filename}

  function checkroot() { :; }
  function is_mapped() { echo "/dev/loop0: [fd02]:9044139 (./centos-6.3_x86_64.raw)"; }
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_mapped_lodev_opts() {
  assertEquals "$(mapped_lodev ${disk_filename})" loop0
}

function test_mapped_lodev_no_opts() {
  mapped_lodev 2>/dev/null
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
