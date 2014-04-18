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

### physdev

function test_add_option_distro_physdev_exists() {
  local physdev=eth0
  local old_physdev=${physdev}

  add_option_distro
  assertEquals "${physdev}" "${old_physdev}"
}

function test_add_option_distro_physdev_empty() {
  local physdev=
  local old_physdev=${physdev}

  add_option_distro
  assertEquals "${physdev}" "${old_physdev}"
}

## shunit2

. ${shunit2_file}
