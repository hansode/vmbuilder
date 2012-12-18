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
  function truncate() { :; }
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_mkdisk_size_zero() {
  mkdisk ${disk_filename} 0 2>/dev/null
  assertNotEquals $? 0
}

function test_mkdisk_size_non_zero() {
  mkdisk ${disk_filename} $(sum_disksize)
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
