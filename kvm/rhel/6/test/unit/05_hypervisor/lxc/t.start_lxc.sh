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

function test_start_lxc() {
  start_lxc
}

## shunit2

. ${shunit2_file}
