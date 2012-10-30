#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

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
  load_distro_driver unknown
  assertNotEquals $? 0
}


## shunit2

. ${shunit2_file}
