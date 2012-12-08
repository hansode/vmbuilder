#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

### set value

function test_render_interface_ovsbridge_br0() {
  render_interface_ovsbridge br0
  assertEquals $? 0
}

function test_render_interface_ovsbridge_br1() {
  render_interface_ovsbridge br1
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
