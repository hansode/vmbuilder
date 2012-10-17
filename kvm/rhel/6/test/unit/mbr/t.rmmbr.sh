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
  truncate -s 10m ${disk_filename}
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
