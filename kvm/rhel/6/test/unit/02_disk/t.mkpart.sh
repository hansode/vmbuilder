#!/bin/bash
#
# requires:
#  bash
#  cd, dirname
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  touch ${disk_filename}

  function checkroot() { :; }
  function parted() { echo parted $*; }
  function udevadm() { echo udevadm $*; }
}

function tearDown() {
  rm -f ${disk_filename}
}

### with default options

function test_mkpart_with_filename() {
  mkpart ${disk_filename} 2>/dev/null
  assertNotEquals $? 0
}

function test_mkpart_with_parttype() {
  mkpart ${disk_filename} primary 2>/dev/null
  assertNotEquals $? 0
}

function test_mkpart_with_parttype_offset() {
  mkpart ${disk_filename} primary 0 2>/dev/null
  assertNotEquals $? 0
}

function test_mkpart_with_parttype_offset_size() {
  mkpart ${disk_filename} primary 0 $(sum_disksize) >/dev/null
  assertEquals $? 0
}

### without default options

function test_mkpart_with_primary_offset0_totalsize_ext2() {
  mkpart ${disk_filename} primary 0 $(sum_disksize) ext2 >/dev/null
  assertEquals $? 0
}

function test_mkpart_with_primary_offset1_totalsize_ext2() {
  mkpart ${disk_filename} primary 1 $(sum_disksize) ext2 >/dev/null
  assertEquals $? 0
}

function test_mkpart_with_primary_offset0_totalsize_swap() {
  mkpart ${disk_filename} primary 0 $(sum_disksize) swap >/dev/null
  assertEquals $? 0
}

function test_mkpart_with_primary_offset1_totalsize_swap() {
  mkpart ${disk_filename} primary 1 $(sum_disksize) swap >/dev/null
  assertEquals $? 0
}

function test_mkpart_with_primary_offset0_totalsize_unknown() {
  mkpart ${disk_filename} primary 0 $(sum_disksize) unknown 2>/dev/null
  assertNotEquals $? 0
}

function test_mkpart_with_primary_offset0_size0_ext2() {
  mkpart ${disk_filename} primary 0 0 ext2 2>/dev/null
  assertNotEquals $? 0
}

function test_mkpart_with_extended_offset0_totalsize_ext2() {
  mkpart ${disk_filename} extended 0 $(sum_disksize) ext2 2>/dev/null
  assertNotEquals $? 0
}

function test_mkpart_with_logical_offset0_totalsize_ext2() {
  mkpart ${disk_filename} logical 0 $(sum_disksize) ext2 2>/dev/null
  assertNotEquals $? 0
}

### whole disk

function test_mkpart_with_primary_offset0_whole_ext2() {
  mkpart ${disk_filename} primary 0 -1 ext2 >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
