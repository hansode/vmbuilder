#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

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
