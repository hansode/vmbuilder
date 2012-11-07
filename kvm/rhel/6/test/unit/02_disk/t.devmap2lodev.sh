#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare lodev=loop0
declare _lsdevmaps="${lodev}p1
${lodev}p2
${lodev}p3
"

## public functions

function setUp() {
  mkdisk ${disk_filename} ${totalsize} 2>/dev/null
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_devmap2lodev() {
  assertEquals $(lsdevmap ${disk_filename} | devmap2lodev) /dev/${lodev}
  assertEquals $? 0
}

function test_hoge() {
  assertEquals $(lsdevmap ${disk_filename} | devmap2lodev) /dev/${lodev}
}

## shunit2

. ${shunit2_file}
