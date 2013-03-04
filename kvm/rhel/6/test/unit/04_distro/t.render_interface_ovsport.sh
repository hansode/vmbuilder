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

function test_render_interface_ovsport_eth0() {
  eval "$(render_interface_ovsport eth0)"

  assertEquals "${DEVICE}" "eth0"
  assertEquals "${TYPE}"   "OVSPort"
}

function test_render_interface_ovsport_eth1() {
  eval "$(render_interface_ovsport eth1)"

  assertEquals "${DEVICE}" "eth1"
  assertEquals "${TYPE}"   "OVSPort"
}

function test_render_interface_ovsport_eth0_br0() {
  local bridge=br0
  eval "$(render_interface_ovsport eth0)"

  assertEquals "${DEVICE}"     "eth0"
  assertEquals "${TYPE}"       "OVSPort"
  assertEquals "${OVS_BRIDGE}" "br0"
}

## shunit2

. ${shunit2_file}
