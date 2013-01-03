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

function test_lxc_destroy() {
  local name=vmbuilder
  lxc_destroy ${name} | egrep -q -w "lxc-destroy -n ${name}"
}

## shunit2

. ${shunit2_file}
