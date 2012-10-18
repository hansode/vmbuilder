#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_preflight_check_hypervisor() {
  preflight_check_hypervisor
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
