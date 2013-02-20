#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  add_option_hypervisor_kvm
}

function test_kvm_dump() {
  eval "$(kvm_dump)"

  assertEquals "${name}"         ""
  assertEquals "${brname}"       "br0"
  assertEquals "${kvm_opts}"     ""
  assertEquals "${mem_size}"     "1024"
  assertEquals "${cpu_num}"      "1"
  assertEquals "${vnc_addr}"     "127.0.0.1"
  assertEquals "${vnc_port}"     "1001"
  assertEquals "${monitor_addr}" "127.0.0.1"
  assertEquals "${monitor_port}" "4444"
  assertEquals "${serial_addr}"  "127.0.0.1"
  assertEquals "${serial_port}"  "5555"
}

## shunit2

. ${shunit2_file}
