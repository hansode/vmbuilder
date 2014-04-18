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

### onboot

function test_add_option_distro_onboot_exists() {
  local onboot=none
  local old_onboot=${onboot}

  add_option_distro
  assertEquals "${onboot}" "${old_onboot}"
}

function test_add_option_distro_onboot_empty() {
  local onboot=
  local old_onboot=${onboot}

  add_option_distro
  assertEquals "${onboot}" "${old_onboot}"
}

## shunit2

. ${shunit2_file}
