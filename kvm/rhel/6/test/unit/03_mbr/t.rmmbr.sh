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
  touch ${disk_filename}

  function dd() { :; }
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_rmmbr_no_opts() {
  rmmbr 2>/dev/null
  assertNotEquals $? 0
}

function test_rmmbr_file_exists() {
  rmmbr ${disk_filename}
  assertEquals $? 0
}


## shunit2

. ${shunit2_file}
