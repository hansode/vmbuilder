#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## functions

function test_extract_dirname_parent_dir() {
  extract_dirname ../
  assertEquals $? 0
}

function test_extract_dirname_current_dir() {
  extract_dirname ./
  assertEquals $? 0
}

function test_extract_dirname_pwd() {
  assertSame "$(extract_dirname ./)" "$(pwd)"
}

function test_extract_dirname_parent_file_not_found() {
  extract_dirname /a/s/d/f
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
