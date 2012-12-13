#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_add_option_hypervisor_lxc() {
  add_option_hypervisor_lxc
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
