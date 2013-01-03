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
}

### distro_ver

function test_add_option_distro_ver_empty() {
  local distro_ver=
  local old_distro_ver=${distro_ver}

  add_option_distro  >/dev/null 2>&1
  assertEquals "${old_distro_ver}" "${distro_ver}"
}

function test_add_option_distro_ver_major() {
  local distro_ver=6
  local old_distro_ver=${distro_ver}

  # 6 -> 6.x
  add_option_distro
  assertNotEquals "${old_distro_ver}" "${distro_ver}"
}

function test_add_option_distro_ver_major_minor() {
  local distro_ver=6.0
  local old_distro_ver=${distro_ver}

  # 6.0 -> 6.0
  add_option_distro
  assertEquals "${old_distro_ver}" "${distro_ver}"
}

## shunit2

. ${shunit2_file}
