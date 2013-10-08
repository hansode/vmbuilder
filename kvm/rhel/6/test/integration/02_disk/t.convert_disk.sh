#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare dest_filename=${disk_filename%%."$(get_suffix ${disk_filename})"}

## public functions

function setUp() {
  add_option_disk
  mkdisk   ${disk_filename} $(sum_disksize) 2>/dev/null
  mkptab   ${disk_filename}
  mapptab  ${disk_filename}
  mkfsdisk ${disk_filename} ext4
}

function tearDown() {
  unmapptab ${disk_filename}
  rm -f     ${disk_filename}
  rm -f     ${dest_filename}.*
}

### no opts

function test_convert_disk_no_opts() {
  convert_disk
  assertNotEquals $? 0
}

### set opts

function test_convert_disk_filename() {
  convert_disk ${disk_filename}
}

function test_convert_disk_filename_destdir() {
  convert_disk ${disk_filename} ${PWD}
  assertEquals $? 0
}

#### raw -> vdi (virtualbox)

function test_convert_disk_filename_destdir_destformat_vdi() {
  convert_disk ${disk_filename} ${PWD} vdi
  assertEquals $? 0
}

#### raw -> vmdk (vmware)

function test_convert_disk_filename_destdir_destformat_vmdk() {
  convert_disk ${disk_filename} ${PWD} vmdk
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
