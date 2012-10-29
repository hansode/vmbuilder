#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_get_distro_major_ver_exists() {
  get_distro_major_ver 6.0
  assertEquals $? 0

  get_distro_major_ver 6
  assertEquals $? 0
}

function test_get_distro_major_ver_empty() {
  get_distro_major_ver ""
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
