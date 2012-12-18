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

function test_qemu_img_path() {
  assertEquals $(qemu_img_path | wc -l) 1
}

## shunit2

. ${shunit2_file}
