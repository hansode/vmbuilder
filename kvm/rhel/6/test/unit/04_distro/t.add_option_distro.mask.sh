#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

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
