#!/bin/bash
#
# requires:
#  bash
#  pwd
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## functions

function test_expand_path_parent_dir() {
  assertEquals "$(expand_path ../)" "${PWD}/.."
}

function test_expand_path_current_dir() {
  assertEquals "$(expand_path ./)" "${PWD}/."
}

function test_expand_path_parent_file_not_found() {
  expand_path /a/s/d/f 2>/dev/null
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
