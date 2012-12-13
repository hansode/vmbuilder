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
  add_option_hypervisor_lxc
}

function test_stop_lxc() {
  stop_lxc
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
