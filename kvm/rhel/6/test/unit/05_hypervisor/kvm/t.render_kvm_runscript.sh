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
}

function test_render_kvm_runscript() {
  render_kvm_runscript >/dev/null 2>&1
  assertNotEquals $? 0
}

function test_render_kvm_runscript_set_name() {
  local name=vmbuilder

  render_kvm_runscript ${name} | egrep -q -w "^name=${name}"
  assertEquals $? 0

  render_kvm_runscript ${name} | grep -q -w "^$(qemu_kvm_path) -name \${name}"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
