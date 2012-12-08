#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_qemu_kvm_path() {
  qemu_kvm_path
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
