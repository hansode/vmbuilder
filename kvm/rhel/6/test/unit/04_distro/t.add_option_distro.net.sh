#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

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
