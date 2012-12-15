#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function setUp() {
  add_option_hypervisor_kvm
  function egrep() { echo egrep $*; }
}

function test_kvm_list() {
  # connect to local tcp/22
  kvm_list
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
