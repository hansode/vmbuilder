#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare disk_filename=_disk.raw.$$

## public functions

function tearDown() {
  rm -f ${disk_filename}
}

function test_mkdisk() {
  mkdisk ${disk_filename} 2>/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
