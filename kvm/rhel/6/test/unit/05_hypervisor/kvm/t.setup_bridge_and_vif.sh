#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

function setUp() {
  function checkroot() { :; }
  function ip() { echo ip $*; }
  function brctl() { echo brctl $*; }
  function shlog() { echo $*; }
}

## public functions

function test_setup_bridge_and_vif() {
  local vm_name=rhel6 mon_port=4444

  setup_bridge_and_vif | egrep -q -w "^ip link set ${vm_name}-${mon_port} up"
  setup_bridge_and_vif | egrep -q -w "^brctl addif br0 ${vm_name}-${mon_port}"
}

## shunit2

. ${shunit2_file}
