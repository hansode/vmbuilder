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

function test_render_interface_ethernet_eth0() {
  eval "$(render_interface_ethernet eth0)"

  assertEquals "${DEVICE}" "eth0"
  assertEquals "${TYPE}"   "Ethernet"
}

function test_render_interface_ethernet_eth1() {
  eval "$(render_interface_ethernet eth1)"

  assertEquals "${DEVICE}" "eth1"
  assertEquals "${TYPE}"   "Ethernet"
}

function test_render_interface_ethernet_eth0_br0() {
  local bridge=br0
  eval "$(render_interface_ethernet eth0)"

  assertEquals "${DEVICE}" "eth0"
  assertEquals "${TYPE}"   "Ethernet"
  assertEquals "${BRIDGE}" "br0"
}

function test_render_interface_ethernet_eth0_bonding() {
  local master=bond0
  eval "$(render_interface_ethernet eth0)"

  assertEquals "bond0" "${MASTER}"
  assertEquals "yes"   "${SLAVE}"
}

## shunit2

. ${shunit2_file}
