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
  distro_ver=4
}

### arch

function test_add_option_distro_centos4() {
  add_option_distro

  assertEquals "${distro_ver}" "${distro_ver_latest}"
}

## shunit2

. ${shunit2_file}
