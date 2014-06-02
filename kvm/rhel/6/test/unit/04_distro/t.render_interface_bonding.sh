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

function test_render_interface_bonding_bond0() {
  eval "$(render_interface_bonding bond0)"

  assertEquals "bond0" "${DEVICE}"
}

function test_render_interface_bonding_bond1() {
  eval "$(render_interface_bonding bond1)"

  assertEquals "bond1" "${DEVICE}"
}

function test_render_interface_bonding_bond0_opts() {
  local bonding_opts="mode=1 failover=1"
  eval "$(render_interface_bonding bond0)"

  assertEquals "${bonding_opts}" "${BONDING_OPTS}"
}

## shunit2

. ${shunit2_file}
