#!/bin/bash
#
# requires:
#  bash
#  cd
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function test_get_suffix_no_opts() {
  get_suffix "" 2>/dev/null
  assertNotEquals "$?" "0"
}

function test_get_suffix_opts() {
  assertEquals "$(get_suffix filename.raw)"           "raw"
  assertEquals "$(get_suffix filename.$$.raw)"        "raw"
  assertEquals "$(get_suffix ${PWD}/filename.$$.raw)" "raw"
}

## shunit2

. ${shunit2_file}
