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

### mac

function test_add_option_distro_mac_exists() {
  local mac=1
  local old_mac=${mac}

  add_option_distro
  assertEquals "${mac}" "${old_mac}"
}

function test_add_option_distro_mac_empty() {
  local mac=
  local old_mac=${mac}

  add_option_distro
  assertEquals "${mac}" "${old_mac}"
}

## shunit2

. ${shunit2_file}
