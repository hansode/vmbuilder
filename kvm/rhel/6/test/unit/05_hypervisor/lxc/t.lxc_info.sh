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
  add_option_hypervisor_lxc

  function checkroot() { :; }
  function shlog() { echo $*; }
}

function test_lxc_info() {
  local name=vmbuilder

  lxc_info ${name} | egrep -q -w "lxc-info -n ${name}"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
