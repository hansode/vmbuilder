#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_preferred_filesystem() {
  preferred_filesystem=ext3
  assertEquals "$(preferred_filesystem)" "${preferred_filesystem}"

  preferred_filesystem=ext4
  assertEquals "$(preferred_filesystem)" "${preferred_filesystem}"
}

## shunit2

. ${shunit2_file}
