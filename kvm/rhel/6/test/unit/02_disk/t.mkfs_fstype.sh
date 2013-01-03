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

function test_mkfs_fstype_empty() {
  mkfs_fstype "" 2>/dev/null
  assertNotEquals "$?" 0
}

function test_mkfs_fstype_ext3() {
  assertEquals "$(mkfs_fstype ext3)" "mkfs.ext3 -F -I 128"
}

function test_mkfs_fstype_ext4() {
  assertEquals "$(mkfs_fstype ext4)" "mkfs.ext4 -F -E lazy_itable_init=1"
}


## shunit2

. ${shunit2_file}
