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
  add_option_hypervisor_openvz

  function checkroot() { :; }
  function shlog() { echo $*; }
}

function test_openvz_stop() {
  local name=vmbuilder

  assertEquals "$(openvz_stop ${name})" "vzctl stop ${name}"
}

## shunit2

. ${shunit2_file}
