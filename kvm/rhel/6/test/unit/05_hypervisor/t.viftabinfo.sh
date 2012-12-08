#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_viftabinfo_default_lines() {
  assertEquals $(viftabinfo | wc -l) 1
}

function test_viftabinfo_default_params() {
  assertEquals "$(viftabinfo)" "rhel6-4444 - br0"
}

## shunit2

. ${shunit2_file}
