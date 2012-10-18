#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## functions

function test_checkroot() {
  [ $UID == 0 ] && {
    checkroot
    assertEquals "$?" "0"
  } || {
    checkroot
    assertNotEquals "$?" "0"
  }
}

## shunit2

. ${shunit2_file}
