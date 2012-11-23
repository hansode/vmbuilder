#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

### distro_name

function test_add_option_distro_name_rhel() {
  local distro_name=rhel
  local old_distro_name=${distro_name}

  add_option_distro
  assertEquals "${old_distro_name}" "${distro_name}"
}

function test_add_option_distro_name_centos() {
  local distro_name=centos
  local distro_ver=6
  local old_distro_name=${distro_name}

  add_option_distro
  assertEquals "${old_distro_name}" "${distro_name}"
}

function test_add_option_distro_name_sl() {
  local distro_name=sl
  local distro_ver=6
  local old_distro_name=${distro_name}

  add_option_distro
  assertEquals "${old_distro_name}" "${distro_name}"
}

function test_add_option_distro_name_fedora() {
  local distro_name=fedora
  local distro_ver=12
  local old_distro_name=${distro_name}

  add_option_distro
  assertEquals "${old_distro_name}" "${distro_name}"
}

function test_add_option_distro_name_empty() {
  local distro_name=
  local old_distro_name=${distro_name}

  add_option_distro
  assertEquals "${old_distro_name}" "${distro_name}"
}

## shunit2

. ${shunit2_file}
