#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

function setUp() {
  add_option_disk
}

function tearDown() {
  rm -f ${disk_filename}
}

### xpart

function test_mkdisk_xpart() {
  local xpart=${abs_dirname}/../../../xpart.txt.example

  mkdisk ${disk_filename} $(sum_disksize)
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
