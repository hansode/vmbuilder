#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

### set value

function test_render_interface_bridge_br0() {
  eval "$(render_interface_bridge br0)"

  assertEquals "${DEVICE}" "br0"
  assertEquals "${TYPE}"   "Bridge"
}

function test_render_interface_bridge_br1() {
  eval "$(render_interface_bridge br1)"

  assertEquals "${DEVICE}" "br1"
  assertEquals "${TYPE}"   "Bridge"
}

## shunit2

. ${shunit2_file}
