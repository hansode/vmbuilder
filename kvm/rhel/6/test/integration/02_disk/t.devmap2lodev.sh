#!/bin/bash
#
# requires:
#  bash
#  cd
#  rm
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdisk  ${disk_filename} $(sum_disksize) 2>/dev/null
  mkptab  ${disk_filename}
  mapptab ${disk_filename}
}

function tearDown() {
  unmapptab ${disk_filename}
  rm -f     ${disk_filename}
}

function test_devmap2lodev() {
  lsdevmap ${disk_filename} | devmap2lodev | egrep ^/dev/
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
