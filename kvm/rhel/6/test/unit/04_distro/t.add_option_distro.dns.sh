#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

### dns

function test_add_option_distro_dns_exists() {
  local dns=1
  local old_dns=${dns}

  add_option_distro
  assertEquals "${old_dns}" "${dns}"
}

function test_add_option_distro_dns_empty() {
  local dns=
  local old_dns=${dns}

  add_option_distro
  assertEquals "${old_dns}" "${dns}"
}

## shunit2

. ${shunit2_file}
