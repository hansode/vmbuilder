#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## functions

function test_qemu_img() {
  which qemu-img
  assertEquals "$?" "0"
}

## shunit2

. ${shunit2_file}
