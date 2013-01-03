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

### baseurl

function test_add_option_distro_baseurl_empty() {
  local baseurl=
  local old_baseurl=${baseurl}

  add_option_distro
  assertNotEquals "${old_baseurl}" "${baseurl}"
}

function test_add_option_distro_baseurl_exists() {
  local baseurl=http://www.example.com/
  local old_baseurl=${baseurl}

  add_option_distro
  assertEquals "${old_baseurl}" "${baseurl}"
}

## shunit2

. ${shunit2_file}
