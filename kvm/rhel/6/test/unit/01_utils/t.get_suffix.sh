#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_get_suffix_no_opts() {
  get_suffix ""
  assertNotEquals "$?" "0"
}

function test_get_suffix_opts() {
  assertEquals "$(get_suffix filename.raw)"           "raw"
  assertEquals "$(get_suffix filename.$$.raw)"        "raw"
  assertEquals "$(get_suffix $(pwd)/filename.$$.raw)" "raw"
}

## shunit2

. ${shunit2_file}
