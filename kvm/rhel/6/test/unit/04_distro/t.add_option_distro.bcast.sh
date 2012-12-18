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

### bcast

function test_add_option_distro_bcast_exists() {
  local bcast=1
  local old_bcast=${bcast}

  add_option_distro
  assertEquals "${old_bcast}" "${bcast}"
}

function test_add_option_distro_bcast_empty() {
  local bcast=
  local old_bcast=${bcast}

  add_option_distro
  assertEquals "${old_bcast}" "${bcast}"
}

## shunit2

. ${shunit2_file}
