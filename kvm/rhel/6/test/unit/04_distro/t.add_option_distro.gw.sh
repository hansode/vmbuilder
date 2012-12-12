#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

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
