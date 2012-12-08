#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_add_option_hypervisor_kvm() {
  add_option_hypervisor_kvm
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
