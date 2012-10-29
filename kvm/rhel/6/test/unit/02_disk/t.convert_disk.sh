#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare dest_formart=vdi
declare dest_filename=${disk_filename%%."$(get_suffix ${disk_filename})"}.${dest_formart}

## public functions

function setUp() {
  mkdisk ${disk_filename} ${totalsize} 2>/dev/null
  mkptab ${disk_filename}
  mapptab ${disk_filename}
  mkfsdisk ${disk_filename}
}

function tearDown() {
  unmapptab ${disk_filename}
  rm -f ${disk_filename}
  rm -f ${dest_filename}
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
  convert_disk ${disk_filename} `pwd`
  assertEquals $? 0
}

function test_convert_disk_filename_destdir_destformat() {
  convert_disk ${disk_filename} `pwd` ${dest_formart}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
