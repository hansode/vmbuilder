#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  add_option_hypervisor_kvm
}

function test_kvm_dump() {
  kvm_dump
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
