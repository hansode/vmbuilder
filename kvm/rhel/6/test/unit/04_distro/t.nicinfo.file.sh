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

function test_nictabinfo_file() {
  nictab=${abs_dirname}/../../../nictab.txt.example
  assertEquals $(nictabinfo | wc -l) 3
}

## shunit2

. ${shunit2_file}
