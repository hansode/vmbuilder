#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## functions

function test_brctl() {
  which brctl
  assertEquals "$?" "0"
}

## shunit2

. ${shunit2_file}
