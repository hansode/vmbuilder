#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function test_load_distro_driver_centos6() {
  load_distro_driver centos6
  assertEquals $? 0
}

function test_load_distro_driver_sl6() {
  load_distro_driver centos6
  assertEquals $? 0
}

function test_load_distro_driver_unknown() {
  load_distro_driver unknown 2>/dev/null
  assertNotEquals $? 0
}


## shunit2

. ${shunit2_file}
