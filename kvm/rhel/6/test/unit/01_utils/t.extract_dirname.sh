#!/bin/bash
#
# requires:
#  bash
#  pwd
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## functions

function test_extract_dirname_parent_dir() {
  assertEquals $(extract_dirname ../) ${PWD}
}

function test_extract_dirname_current_dir() {
  assertEquals $(extract_dirname ./) ${PWD}
}

function test_extract_dirname_pwd() {
  assertSame "$(extract_dirname ./)" "${PWD}"
}

function test_extract_dirname_parent_file_not_found() {
  extract_dirname /a/s/d/f 2>/dev/null
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
