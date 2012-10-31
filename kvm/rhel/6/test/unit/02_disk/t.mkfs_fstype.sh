#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_mkfs_fstype_empty() {
  mkfs_fstype ""
  assertNotEquals "$?" 0
}

function test_mkfs_fstype_ext3() {
  mkfs_fstype ext3
  assertEquals "$?" 0
}

function test_mkfs_fstype_ext4() {
  mkfs_fstype ext4
  assertEquals "$?" 0
}


## shunit2

. ${shunit2_file}
