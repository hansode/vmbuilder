#!/bin/bash
#
# requires:
#  bash
#  cd
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdisk ${disk_filename} $(sum_disksize) 2>/dev/null
  parted --script ${disk_filename} mklabel msdos
}

function tearDown() {
  rm -f ${disk_filename}
}

### with default options

function test_mkpart_with_filename() {
  mkpart ${disk_filename}
  assertNotEquals $? 0
}

function test_mkpart_with_parttype() {
  mkpart ${disk_filename} primary
  assertNotEquals $? 0
}

function test_mkpart_with_parttype_offset() {
  mkpart ${disk_filename} primary 0
  assertNotEquals $? 0
}

function test_mkpart_with_parttype_offset_size() {
  mkpart ${disk_filename} primary 0 $(sum_disksize)
  assertEquals $? 0
}

### without default options

function test_mkpart_with_primary_offset0_totalsize_ext2() {
  mkpart ${disk_filename} primary 0 $(sum_disksize) ext2
  assertEquals $? 0
}

function test_mkpart_with_primary_offset1_totalsize_ext2() {
  mkpart ${disk_filename} primary 1 $(sum_disksize) ext2
  assertEquals $? 0
}

function test_mkpart_with_primary_offset0_totalsize_swap() {
  mkpart ${disk_filename} primary 0 $(sum_disksize) swap
  assertEquals $? 0
}

function test_mkpart_with_primary_offset1_totalsize_swap() {
  mkpart ${disk_filename} primary 1 $(sum_disksize) swap
  assertEquals $? 0
}

function test_mkpart_with_primary_offset0_totalsize_unknown() {
  mkpart ${disk_filename} primary 0 $(sum_disksize) unknown
  assertNotEquals $? 0
}

function test_mkpart_with_primary_offset0_size0_ext2() {
  mkpart ${disk_filename} primary 0 0 ext2
  assertNotEquals $? 0
}

function test_mkpart_with_extended_offset0_totalsize_ext2() {
  mkpart ${disk_filename} extended 0 $(sum_disksize) ext2
  assertNotEquals $? 0
}

function test_mkpart_with_logical_offset0_totalsize_ext2() {
  mkpart ${disk_filename} logical 0 $(sum_disksize) ext2
  assertNotEquals $? 0
}

### whole disk

function test_mkpart_with_primary_offset0_whole_ext2() {
  mkpart ${disk_filename} primary 0 -1 ext2
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
