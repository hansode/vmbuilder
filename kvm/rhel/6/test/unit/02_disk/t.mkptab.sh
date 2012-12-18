#!/bin/bash
#
# requires:
#  bash
#  cd, dirname
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  touch ${disk_filename}

  function parted() { :; }
  function xptabproc() { cat >/dev/null; }
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_mkptab_all_zero() {
  mkptab ${disk_filename} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
