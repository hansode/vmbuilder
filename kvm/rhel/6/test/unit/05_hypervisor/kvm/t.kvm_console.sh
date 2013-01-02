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
  function telnet() { echo telnet $*; }
}

function test_kvm_console_no_opts() {
  assertEquals "$(kvm_console)" "telnet 127.0.0.1 5555"
}

function test_kvm_console_set_bindaddr() {
  local host=127.0.0.1 port=5556

  assertEquals "$(kvm_console ${host} ${port})" "telnet ${host} ${port}"
}

## shunit2

. ${shunit2_file}
