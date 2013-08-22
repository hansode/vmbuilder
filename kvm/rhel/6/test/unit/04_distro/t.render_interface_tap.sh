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

function test_render_interface_tap_tap0() {
  eval "$(render_interface_tap tap0)"

  assertEquals "${DEVICE}" "tap0"
  assertEquals "${TYPE}"   "Tap"
}

function test_render_interface_tap_tap1() {
  eval "$(render_interface_tap tap1)"

  assertEquals "${DEVICE}" "tap1"
  assertEquals "${TYPE}"   "Tap"
}

function test_render_interface_tap_tap0_br0() {
  local bridge=br0
  eval "$(render_interface_tap tap0)"

  assertEquals "${DEVICE}" "tap0"
  assertEquals "${TYPE}"   "Tap"
  assertEquals "${BRIDGE}" "br0"
}

## shunit2

. ${shunit2_file}
