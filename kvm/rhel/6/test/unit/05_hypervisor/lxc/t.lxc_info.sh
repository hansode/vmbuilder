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
  add_option_hypervisor_lxc

  function checkroot() { echo checkroot $*; }
  function shlog() { echo shlog $*; }
}

function test_lxc_info() {
  lxc_info vmbuilder
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
