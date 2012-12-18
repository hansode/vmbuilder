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

### gw

function test_add_option_distro_gw_exists() {
  local gw=1
  local old_gw=${gw}

  add_option_distro
  assertEquals "${old_gw}" "${gw}"
}

function test_add_option_distro_gw_empty() {
  local gw=
  local old_gw=${gw}

  add_option_distro
  assertEquals "${old_gw}" "${gw}"
}

## shunit2

. ${shunit2_file}
