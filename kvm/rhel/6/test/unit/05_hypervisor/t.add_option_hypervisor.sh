#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare hypervisor=

## public functions

### hypervisor

function test_add_option_hypervisor_hypervisor_null() {
  local hypervisor=null
  local old_hypervisor=${hypervisor}

  add_option_hypervisor >/dev/null
  assertEquals "${old_hypervisor}" "${hypervisor}"
}

function test_add_option_hypervisor_hypervisor_kvm() {
  local hypervisor=kvm
  local old_hypervisor=${hypervisor}

  add_option_hypervisor >/dev/null
  assertEquals "${old_hypervisor}" "${hypervisor}"
}

function test_add_option_hypervisor_hypervisor_lxc() {
  local hypervisor=lxc
  local old_hypervisor=${hypervisor}

  add_option_hypervisor >/dev/null
  assertEquals "${old_hypervisor}" "${hypervisor}"
}

function test_add_option_hypervisor_hypervisor_openvz() {
  local hypervisor=openvz
  local old_hypervisor=${hypervisor}

  add_option_hypervisor >/dev/null
  assertEquals "${old_hypervisor}" "${hypervisor}"
}

function test_add_option_hypervisor_hypervisor_empty() {
  local hypervisor=
  local old_hypervisor=${hypervisor}

  add_option_hypervisor >/dev/null 2>&1
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
