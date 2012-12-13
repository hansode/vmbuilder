#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_build_kvm_opts() {
  build_kvm_opts
  assertEquals $? 0
}

function test_build_kvm_opts_name() {
  local name=vmbulder

  build_kvm_opts | egrep -- "-name ${name}"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
