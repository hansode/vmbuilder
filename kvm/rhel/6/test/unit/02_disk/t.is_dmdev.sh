#!/bin/bash
#
# requires:
#  bash
#  cd
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## functions

function test_is_dmdev_device() {
  [[ -b /dev/dm-0 ]] && {
    is_dmdev /dev/dm-0
    assertEquals "$?" "0"
  } || :
}

function test_is_dmdev_text() {
  is_dmdev /var/log/messages
  assertNotEquals "$?" "0"
}

function test_is_dmdev_empty() {
  is_dmdev 2>/dev/null
  assertNotEquals "$?" "0"
}

## shunit2

. ${shunit2_file}
