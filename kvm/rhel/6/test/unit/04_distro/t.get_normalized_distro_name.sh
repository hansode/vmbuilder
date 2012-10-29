#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_get_normalized_distro_name_defined_rhel() {
  get_normalized_distro_name rhel
  assertEquals $? 0
}

function test_get_normalized_distro_name_defined_centos() {
  get_normalized_distro_name centos
  assertEquals $? 0
}

function test_get_normalized_distro_name_defined_sl() {
  get_normalized_distro_name sl
  assertEquals $? 0

  get_normalized_distro_name scientific
  assertEquals $? 0

  get_normalized_distro_name scientificlinux
  assertEquals $? 0
}

function test_get_normalized_distro_name_undefined() {
  get_normalized_distro_name unknown
  assertNotEquals $? 0

  get_normalized_distro_name ""
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
