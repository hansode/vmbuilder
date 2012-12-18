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

### hostname

function test_add_option_distro_hostname_exists() {
  local hostname=1
  local old_hostname=${hostname}

  add_option_distro
  assertEquals "${old_hostname}" "${hostname}"
}

function test_add_option_distro_hostname_empty() {
  local hostname=
  local old_hostname=${hostname}

  add_option_distro
  assertEquals "${old_hostname}" "${hostname}"
}

## shunit2

. ${shunit2_file}
