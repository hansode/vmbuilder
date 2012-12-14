#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

### re-initialize variables for this unit test

## public functions

function test_routetabinfo_file() {
  local routetab=${abs_dirname}/../../../examples/routetab.txt.example
  assertEquals "$(routetabinfo | wc -l)" "$(egrep -v '^$|^#' ${routetab} | wc -l)"
}

## shunit2

. ${shunit2_file}
