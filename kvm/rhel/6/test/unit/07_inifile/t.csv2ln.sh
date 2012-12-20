#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## functions

function test_csv2ln_args() {
  assertEquals "$(csv2ln "a, b, c")" "a
b
c"
}

function test_csv2ln_filter() {
  assertEquals "$(echo "a, b, c" | csv2ln)" "a
b
c"
}


## shunit2

. ${shunit2_file}
