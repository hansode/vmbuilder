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

function test_kvm_console_no_opts() {
  kvm_console
  assertEquals $? 0
}

function test_kvm_console_set_bindaddr() {
  kvm_console 127.0.0.1 5556
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
