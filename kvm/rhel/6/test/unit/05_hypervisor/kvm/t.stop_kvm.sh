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
}

function test_stop_kvm() {
  # connect to local tcp/22
  stop_kvm 127.0.0.1 22
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
