#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_render_routing_empty() {
  render_routing 2>/dev/null
  assertNotEquals $? 0
}

## cidr

function test_render_routing_defined_cidr() {
  local cidr=10.0.2.0/24 gw=10.0.2.2

  render_routing eth0 | egrep -q -w ^${cidr}
  assertEquals $? 0
}

function test_render_routing_undefined_cidr() {
  local cidr= gw=10.0.2.2

  render_routing eth0 | egrep -q -w ^default
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
