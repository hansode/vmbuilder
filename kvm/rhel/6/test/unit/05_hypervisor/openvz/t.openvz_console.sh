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

function test_openvz_console() {
  local name=vmbuilder

  openvz_console ${name} | egrep -q -w "^vzctl console ${name}"
}

## shunit2

. ${shunit2_file}
