#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_qemu_img_path() {
  qemu_img_path
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
