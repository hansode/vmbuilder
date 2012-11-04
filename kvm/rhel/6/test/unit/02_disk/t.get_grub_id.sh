#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_get_grub_id() {
  assertEquals $(get_grub_id) 0
}

## shunit2

. ${shunit2_file}
