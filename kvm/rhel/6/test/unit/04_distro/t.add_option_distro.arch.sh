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

### arch

function test_add_option_distro_arch_empty() {
  local distro_arch=
  local old_distro_arch=${distro_arch}

  add_option_distro
  assertNotEquals "${old_distro_arch}" "${distro_arch}"
}

function test_add_option_distro_arch_i686() {
  local distro_arch=i686
  local old_distro_arch=${distro_arch}

  add_option_distro
  assertEquals "${old_distro_arch}" "${distro_arch}"
}

function test_add_option_distro_arch_i586() {
  local distro_arch=i586
  local old_distro_arch=${distro_arch}

  add_option_distro
  assertNotEquals "${old_distro_arch}" "${distro_arch}"
}

function test_add_option_distro_arch_i386() {
  local distro_arch=i386
  local old_distro_arch=${distro_arch}

  add_option_distro
  assertNotEquals "${old_distro_arch}" "${distro_arch}"
}

function test_add_option_distro_arch_x86_64() {
  local distro_arch=x86_64
  local old_distro_arch=${distro_arch}

  add_option_distro
  assertEquals "${old_distro_arch}" "${distro_arch}"
}

## shunit2

. ${shunit2_file}
