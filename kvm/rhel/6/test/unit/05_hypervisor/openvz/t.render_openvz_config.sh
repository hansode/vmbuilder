#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function setUp() {
  add_option_hypervisor_openvz
}

function test_render_openvz_config() {
  render_openvz_config
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
