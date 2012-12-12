#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdisk ${disk_filename} $(sum_disksize) 2>/dev/null
  mkptab ${disk_filename}
  mapptab ${disk_filename}
}

function tearDown() {
  unmapptab ${disk_filename}
  rm -f ${disk_filename}
}

### no opts

function test_mkfsdisk() {
  mkfsdisk ${disk_filename}
  assertNotEquals $? 0
}

### set fstype

function test_mkfsdisk_ext3() {
  mkfsdisk ${disk_filename} ext3
  assertEquals $? 0
}

function test_mkfsdisk_ext4() {
  mkfsdisk ${disk_filename} ext4
  assertEquals $? 0
}

### set opts

function test_mkfsdisk_default_max_mount_count() {
  local max_mount_count=37

  mkfsdisk ${disk_filename} ext3
  assertEquals $? 0
}

function test_mkfsdisk_unlimited_max_mount_count() {
  local max_mount_count=-1

  mkfsdisk ${disk_filename} ext3
  assertEquals $? 0
}

function test_mkfsdisk_default_interval_between_check() {
  local interval_between_check=180

  mkfsdisk ${disk_filename} ext3
  assertEquals $? 0
}

function test_mkfsdisk_unlimited_interval_between_check() {
  local interval_between_check=-1

  mkfsdisk ${disk_filename} ext3
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
