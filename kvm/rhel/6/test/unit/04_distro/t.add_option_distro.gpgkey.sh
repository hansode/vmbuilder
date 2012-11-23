#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function setUp() {
  distro_name=centos
  distro_ver=6
}

### gpgkey

function test_add_option_distro_gpgkey_empty() {
  local gpgkey=
  local old_gpgkey=${gpgkey}

  add_option_distro
  assertNotEquals "${old_gpgkey}" "${gpgkey}"
}

function test_add_option_distro_gpgkey_exists() {
  local gpgkey=asdf
  local old_gpgkey=${gpgkey}

  add_option_distro
  assertEquals "${old_gpgkey}" "${gpgkey}"
}

## shunit2

. ${shunit2_file}
