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

### rootpass

function test_add_option_distro_rootpass_empty() {
  local rootpass=
  local old_rootpass=${rootpass}

  add_option_distro
  assertEquals "${old_rootpass}" "${rootpass}"
}

function test_add_option_distro_rootpass_defined() {
  local rootpass=asdf
  local old_rootpass=${rootpass}

  add_option_distro
  assertEquals "${old_rootpass}" "${rootpass}"
}

## shunit2

. ${shunit2_file}
