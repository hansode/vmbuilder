#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

### re-initialize variables for this unit test

## public functions

function test_routetabinfo_file() {
  local routetab=${abs_dirname}/../../../examples/routetab.txt.example
  assertEquals "$(routetabinfo | wc -l)" "$(egrep -v '^$|^#' ${routetab} | wc -l)"
}

## shunit2

. ${shunit2_file}
