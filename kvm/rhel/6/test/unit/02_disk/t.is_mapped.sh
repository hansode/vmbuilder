#!/bin/bash
#
# requires:
#  bash
#  cd
#  touch, rm
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare inode=12345

## public functions

function setUp() {
  touch ${disk_filename}

  function checkroot() { :; }
  function inodeof() { echo -n ${inode}; }
  function losetup() { echo "/dev/loop0: [fd02]:${inode} (${disk_filename})"; }
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_is_mapped_no() {
  function losetup() { :; }

  is_mapped ${disk_filename} >/dev/null
  assertNotEquals $? 0
}

function test_is_mapped_yes() {
  is_mapped ${disk_filename} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
