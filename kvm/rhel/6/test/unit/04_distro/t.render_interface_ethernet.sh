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

function test_render_interface_ethernet_eth0() {
  render_interface_ethernet eth0
  assertEquals $? 0
}

function test_render_interface_ethernet_eth1() {
  render_interface_ethernet eth1
  assertEquals $? 0
}

function test_render_interface_ethernet_eth0_br0() {
  local bridge=br0
  render_interface_ethernet eth0
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
