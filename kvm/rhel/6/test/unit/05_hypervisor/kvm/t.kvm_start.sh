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

  function qemu_kvm_path() { echo /usr/libexec/qemu-kvm; }
  function shlog() { echo $*; }
  function checkroot() { echo checkroot $*; }
}

function test_kvm_start_no_opts() {
  kvm_start >/dev/null 2>&1
  assertNotEquals $? 0
}

function test_kvm_start_set_opts() {
  local name=vmbuilder bridge_if=br0 mon_port=4444

  kvm_start ${name} | egrep -q -w "^$(qemu_kvm_path) -name ${name}"
  assertEquals $? 0

  kvm_start ${name} | egrep -q -w "^ip link set ${name}-${mon_port} up"
  assertEquals $? 0

  kvm_start ${name} | egrep -q -w "^brctl addif ${bridge_if} ${name}-${mon_port}"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
