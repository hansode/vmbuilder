#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_gen_macaddr_no_opts() {
  gen_macaddr
  assertEquals $? 0
}

function test_gen_macaddr_set_offset() {
  gen_macaddr 1
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
