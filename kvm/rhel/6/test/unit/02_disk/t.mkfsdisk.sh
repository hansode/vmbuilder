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
  touch ${disk_filename}

  function checkroot() { :; }
  function xptabproc() { cat; }
}

function tearDown() {
  rm -f ${disk_filename}
}

### no opts

function test_mkfsdisk_no_fstype() {
  mkfsdisk ${disk_filename} 2>/dev/null
  assertNotEquals $? 0
}

function test_mkfsdisk_ext4() {
  mkfsdisk ${disk_filename} ext4 >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
