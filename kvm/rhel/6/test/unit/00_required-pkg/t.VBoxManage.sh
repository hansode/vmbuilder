#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## functions

function test_VBoxManage() {
  which VBoxManage
  assertEquals "$?" "0"
}

## shunit2

. ${shunit2_file}
