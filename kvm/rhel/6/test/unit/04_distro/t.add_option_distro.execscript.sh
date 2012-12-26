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

### execscript

function test_add_option_distro_execscript_exists() {
  local execscript=1
  local old_execscript=${execscript}

  add_option_distro
  assertEquals "${old_execscript}" "${execscript}"
}

function test_add_option_distro_execscript_empty() {
  local execscript=
  local old_execscript=${execscript}

  add_option_distro
  assertEquals "${old_execscript}" "${execscript}"
}

## shunit2

. ${shunit2_file}
