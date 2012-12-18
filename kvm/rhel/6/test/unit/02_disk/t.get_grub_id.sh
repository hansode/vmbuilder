#!/bin/bash
#
# requires:
#  bash
#  cd, dirname
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function test_get_grub_id() {
  assertEquals $(get_grub_id) 0
}

## shunit2

. ${shunit2_file}
