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

  function checkroot() { :; }
  function shlog() { echo $*; }
}

function test_lxc_console() {
  local name=vmbuilder
  assertEquals "$(lxc_console ${name})" "lxc-console -n ${name}"
}

## shunit2

. ${shunit2_file}
