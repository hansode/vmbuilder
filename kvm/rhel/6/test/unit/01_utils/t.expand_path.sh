#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## functions

function test_expand_path_parent_dir() {
  expand_path ../
  assertEquals $? 0
}

function test_expand_path_current_dir() {
  expand_path ./
  assertEquals $? 0
}

function test_expand_path_parent_file_not_found() {
  expand_path /a/s/d/f
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
