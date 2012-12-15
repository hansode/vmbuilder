#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_render_fstab() {
  render_fstab
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
