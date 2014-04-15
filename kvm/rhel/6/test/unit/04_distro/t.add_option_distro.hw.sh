#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  distro_name=centos
  distro_ver=6
}

### hw

function test_add_option_distro_hw_exists() {
  local hw=1
  local old_hw=${hw}

  add_option_distro
  assertEquals "${hw}" "${old_hw}"
}

function test_add_option_distro_hw_empty() {
  local hw=
  local old_hw=${hw}

  add_option_distro
  assertEquals "${hw}" "${old_hw}"
}

## shunit2

. ${shunit2_file}
