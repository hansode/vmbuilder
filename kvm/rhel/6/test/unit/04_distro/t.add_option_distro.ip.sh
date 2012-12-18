#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  distro_name=centos
  distro_ver=6
}

### ip

function test_add_option_distro_ip_exists() {
  local ip=1
  local old_ip=${ip}

  add_option_distro
  assertEquals "${old_ip}" "${ip}"
}

function test_add_option_distro_ip_empty() {
  local ip=
  local old_ip=${ip}

  add_option_distro
  assertEquals "${old_ip}" "${ip}"
}

## shunit2

. ${shunit2_file}
