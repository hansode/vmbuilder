#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

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
