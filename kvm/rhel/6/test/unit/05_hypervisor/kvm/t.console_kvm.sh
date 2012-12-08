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
  function telnet() { echo telnet $*; }
}

function test_console_kvm_no_opts() {
  console_kvm
  assertEquals $? 0
}

function test_console_kvm_set_bindaddr() {
  console_kvm 127.0.0.1 5556
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
