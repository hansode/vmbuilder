#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  dns= dns1= dns2=
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_render_resolv_conf_no_dns() {
  assertEquals "$(render_resolv_conf)" "nameserver 8.8.8.8"
  assertEquals $? 0
}

function test_render_resolv_conf_defined_dns() {
  local dns1=8.8.8.8 dns2=8.8.4.4
  local dns="${dns1} ${dns2}"

  assertEquals "$(render_resolv_conf)" "nameserver ${dns1}
nameserver ${dns2}"
}

## shunit2

. ${shunit2_file}
