#!/bin/bash
#
# requires:
#  bash
#  cd
#  touch, rm
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  :
}

function tearDown() {
  :
}

### no opts

function test_validate_image_format_type_no_opts() {
  validate_image_format_type 2>/dev/null
  assertNotEquals $? 0
}

### set opts

function test_validate_image_format_type_qcow2() {
  validate_image_format_type qcow2 >/dev/null
  assertEquals $? 0
}

function test_validate_image_format_type_vdi() {
  validate_image_format_type vdi >/dev/null
  assertEquals $? 0
}

function test_validate_image_format_type_vmdk() {
  validate_image_format_type vmdk >/dev/null
  assertEquals $? 0
}

function test_validate_image_format_type_unknown() {
  validate_image_format_type unknown 2>/dev/null
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
