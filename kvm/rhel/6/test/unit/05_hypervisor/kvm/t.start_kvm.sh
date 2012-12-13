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

  function shlog() { echo shlog $*; }
  function checkroot() { echo checkroot $*; }
}

function test_start_kvm_no_opts() {
  start_kvm
  assertNotEquals $? 0
}

function test_start_kvm_set_opts() {
  start_kvm vmbuilder
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
