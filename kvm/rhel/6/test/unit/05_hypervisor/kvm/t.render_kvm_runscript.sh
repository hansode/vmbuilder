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

function test_render_kvm_runscript() {
  render_kvm_runscript
  assertNotEquals $? 0
}

function test_render_kvm_runscript_set_name() {
  local name=vmbuilder

  render_kvm_runscript ${name}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
