#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_add_option_distro() {
  baseurl=
  old_baseurl=${baseurl}
  add_option_distro
  assertNotEquals "${old_baseurl}" "${baseurl}"

  distro_name=
  old_distro_name=${distro_name}
  add_option_distro
  assertNotEquals "${old_distro_name}" "${distro_name}"
}

## shunit2

. ${shunit2_file}
