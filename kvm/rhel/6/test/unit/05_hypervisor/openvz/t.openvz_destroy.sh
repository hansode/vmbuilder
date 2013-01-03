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
  add_option_hypervisor_openvz

  function checkroot() { :; }
  function shlog() { echo $*; }
}

function test_openvz_destroy() {
  local name=vmbuilder

  assertEquals "$(openvz_destroy ${name})" "vzctl destroy ${name}"
}

## shunit2

. ${shunit2_file}
