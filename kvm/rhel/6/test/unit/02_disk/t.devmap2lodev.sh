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

function test_devmap2lodev_loop() {
  local loopdev=loop0

  assertEquals "$(echo ${loopdev}p1 | devmap2lodev)" /dev/${loopdev}
}

function test_devmap2lodev_nonloop() {
  assertEquals "$(echo asdf | devmap2lodev)" ""
}

## shunit2

. ${shunit2_file}
