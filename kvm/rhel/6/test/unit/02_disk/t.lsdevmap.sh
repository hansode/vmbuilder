#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare _lsdevmaps="loop0p1
loop0p2
loop0p3
"

## public functions

function setUp() {
  mkdisk ${disk_filename} ${totalsize} 2>/dev/null
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_lsdevmap() {
  lsdevmap ${disk_filename}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
