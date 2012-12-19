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

  function shlog() { echo shlog $*; }
  function checkroot() { echo checkroot $*; }
}

function test_kvm_start_no_opts() {
  kvm_start
  assertNotEquals $? 0
}

function test_kvm_start_set_opts() {
  kvm_start vmbuilder
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
