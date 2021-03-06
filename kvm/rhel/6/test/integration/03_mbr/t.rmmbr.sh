#!/bin/bash
#
# requires:
#   bash
#  touch, rm
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdisk ${disk_filename} 10
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_rmmbr() {
  rmmbr ${disk_filename} 2>/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
