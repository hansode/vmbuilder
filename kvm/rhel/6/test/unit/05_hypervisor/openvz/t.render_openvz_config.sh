#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  add_option_hypervisor_openvz
}

function test_render_openvz_config() {
  render_openvz_config >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
