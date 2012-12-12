#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

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
