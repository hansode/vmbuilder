#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function test_get_distro_major_ver_exists() {
  assertEquals "$(get_distro_major_ver 6.0)" "6"

  assertEquals "$(get_distro_major_ver 6)" "6"
}

function test_get_distro_major_ver_empty() {
  get_distro_major_ver "" 2>/dev/null
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
