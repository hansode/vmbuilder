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

function test_render_interface_vlan_vlan0() {
  eval "$(render_interface_vlan vlan0)"

  assertEquals "vlan0" "${DEVICE}"
}

function test_render_interface_vlan_vlan1() {
  eval "$(render_interface_vlan vlan1)"

  assertEquals "vlan1" "${DEVICE}"
}

function test_render_interface_vlan_vlan0_br0() {
  local bridge=br0
  eval "$(render_interface_vlan vlan0)"

  assertEquals "vlan0" "${DEVICE}"
  assertEquals "br0"   "${BRIDGE}"
}

function test_render_interface_vlan_physdev() {
  local physdev=eth0
  eval "$(render_interface_vlan vlan0)"

  assertEquals "vlan0"  "${DEVICE}"
  assertEquals "eth0"   "${PHYSDEV}"
}

## shunit2

. ${shunit2_file}
