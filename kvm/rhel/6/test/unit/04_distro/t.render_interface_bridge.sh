#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

### set value

function test_render_interface_bridge_br0() {
  render_interface_bridge br0
  assertEquals $? 0
}

function test_render_interface_bridge_br1() {
  local ip=192.0.2.1
  render_interface_bridge br1
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
