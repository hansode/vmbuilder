#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function test_get_normalized_distro_name_defined_rhel() {
  assertEquals "$(get_normalized_distro_name rhel)" "rhel"
}

function test_get_normalized_distro_name_defined_centos() {
  assertEquals "$(get_normalized_distro_name centos)" "centos"
}

function test_get_normalized_distro_name_defined_sl() {
  assertEquals "$(get_normalized_distro_name sl)" "sl"

  assertEquals "$(get_normalized_distro_name scientific)" "sl"

  assertEquals "$(get_normalized_distro_name scientificlinux)" "sl"
}

function test_get_normalized_distro_name_undefined() {
  get_normalized_distro_name unknown 2>/dev/null
  assertNotEquals $? 0

  get_normalized_distro_name "" 2>/dev/null
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
