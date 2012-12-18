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
  distro_name=centos
  distro_ver=6
}

### net

function test_add_option_distro_net_exists() {
  local net=1
  local old_net=${net}

  add_option_distro
  assertEquals "${old_net}" "${net}"
}

function test_add_option_distro_net_empty() {
  local net=
  local old_net=${net}

  add_option_distro
  assertEquals "${old_net}" "${net}"
}

## shunit2

. ${shunit2_file}
