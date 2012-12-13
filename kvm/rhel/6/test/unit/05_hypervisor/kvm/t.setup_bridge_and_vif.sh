#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

function setUp() {
  function checkroot() { echo checkroot $*; }
  function ip() { echo ip $*; }
  function brctl() { echo brctl $*; }
}

## public functions

function test_setup_bridge_and_vif() {
  setup_bridge_and_vif
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
