#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

### re-initialize variables for this unit test

## public functions

function test_nictabinfo_file() {
  local nictab=${abs_dirname}/../../../examples/nictab.txt.example
  assertEquals "$(nictabinfo | wc -l)" "$(egrep -v '^$|^#' ${nictab} | wc -l)"
}

## shunit2

. ${shunit2_file}
