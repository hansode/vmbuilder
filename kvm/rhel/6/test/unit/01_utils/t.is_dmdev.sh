#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## functions

function test_is_dmdev_device() {
  is_dmdev /dev/dm-0
  assertEquals "$?" "0"
}

function test_is_dmdev_text() {
  is_dmdev /var/log/messages
  assertNotEquals "$?" "0"
}

function test_is_dmdev_empty() {
  is_dmdev
  assertNotEquals "$?" "0"
}

## shunit2

. ${shunit2_file}
