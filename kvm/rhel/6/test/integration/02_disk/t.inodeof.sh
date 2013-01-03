#!/bin/bash
#
# requires:
#  bash
#  cd
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## functions

declare inode_file=inode.$$

function setUp() {
  touch ${inode_file}
}

function tearDown() {
  rm -f ${inode_file}
}

function test_inodeof_file_exists() {
  inodeof ${inode_file}
  assertEquals $? 0
}

function test_inodeof_file_exists_compare_using_ls() {
  assertEquals "$(inodeof ${inode_file})" "$(ls -i ${inode_file} | awk '{print $1}')"
}

function test_inodeof_file_not_found() {
  inodeof /${inode_file}
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
