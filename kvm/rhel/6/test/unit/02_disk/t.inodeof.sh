#!/bin/bash
#
# requires:
#  bash
#  cd, dirname
#  touch, rm
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## functions

declare inode_file=inode.$$

function setUp() {
  touch ${inode_file}

  function stat() { echo stat $*; }
}

function tearDown() {
  rm -f ${inode_file}
}

function test_inodeof_file_exists() {
  inodeof ${inode_file} >/dev/null
  assertEquals $? 0
}

function test_inodeof_file_not_found() {
  inodeof /${inode_file} 2>/dev/null
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
