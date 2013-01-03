#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function test_preferred_grub_grub() {
  local preferred_grub=grub

  assertEquals "$(preferred_grub)" "${preferred_grub}"
}

function test_preferred_grub_grub2() {
  local preferred_grub=grub2

  assertEquals "$(preferred_grub)" "${preferred_grub}"
}


## shunit2

. ${shunit2_file}
