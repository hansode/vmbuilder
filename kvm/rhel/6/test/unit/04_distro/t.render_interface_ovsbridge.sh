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

function test_render_interface_ovsbridge_br0() {
  eval "$(render_interface_ovsbridge br0)"

  assertEquals "${DEVICE}"        "br0"
  assertEquals "${TYPE}"          "OVSBridge"
  assertEquals "${NM_CONTROLLED}" "no"
  assertEquals "${DEVICETYPE}"    "ovs"
  assertEquals "${OVS_EXTRA}"     " set bridge     ${DEVICE} other_config:disable-in-band=true --\
 set-fail-mode  ${DEVICE} secure --
"
}

function test_render_interface_ovsbridge_br1() {
  eval "$(render_interface_ovsbridge br1)"

  assertEquals "${DEVICE}"        "br1"
  assertEquals "${TYPE}"          "OVSBridge"
  assertEquals "${NM_CONTROLLED}" "no"
  assertEquals "${DEVICETYPE}"    "ovs"
  assertEquals "${OVS_EXTRA}"     " set bridge     ${DEVICE} other_config:disable-in-band=true --\
 set-fail-mode  ${DEVICE} secure --
"
}

## shunit2

. ${shunit2_file}
