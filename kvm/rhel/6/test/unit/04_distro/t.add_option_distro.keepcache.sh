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

### keepcache

function test_add_option_distro_keepcache_empty() {
  local keepcache=
  local old_keepcache=${keepcache}

  add_option_distro
  assertNotEquals "${old_keepcache}" "${keepcache}"
}

function test_add_option_distro_keepcache_0() {
  local keepcache=0
  local old_keepcache=${keepcache}

  add_option_distro
  assertEquals "${old_keepcache}" "${keepcache}"
}

function test_add_option_distro_keepcache_1() {
  local keepcache=1
  local old_keepcache=${keepcache}

  add_option_distro
  assertEquals "${old_keepcache}" "${keepcache}"
}

function test_add_option_distro_keepcache_invalid() {
  local keepcache=2
  local old_keepcache=${keepcache}

  add_option_distro
  # keepcache validation is in configure_keepcache.
  assertEquals "${old_keepcache}" "${keepcache}"
}

## shunit2

. ${shunit2_file}
