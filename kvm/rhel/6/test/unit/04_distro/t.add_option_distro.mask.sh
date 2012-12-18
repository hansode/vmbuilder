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

### mask

function test_add_option_distro_mask_exists() {
  local mask=1
  local old_mask=${mask}

  add_option_distro
  assertEquals "${old_mask}" "${mask}"
}

function test_add_option_distro_mask_empty() {
  local mask=
  local old_mask=${mask}

  add_option_distro
  assertEquals "${old_mask}" "${mask}"
}

## shunit2

. ${shunit2_file}
