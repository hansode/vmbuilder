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

function test_lxc_start() {
  local name=vmbuilder

  lxc_start ${name} | egrep -q -w "lxc-start -n ${name} -d -l DEBUG -o ${abs_dirname}/lxc.log"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
