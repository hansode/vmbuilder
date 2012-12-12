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
  touch ${disk_filename}

  function VBoxManage() { echo VBoxManage $*; }
  function qemu_img_path() { echo qemu_img_path $*; }
}

function tearDown() {
  rm -f ${disk_filename}
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
  convert_disk ${disk_filename} $(pwd)
  assertEquals $? 0
}

function test_convert_disk_filename_destdir_destformat_vdi() {
  convert_disk ${disk_filename} $(pwd) vdi
  assertEquals $? 0
}

function test_convert_disk_filename_destdir_destformat_vmdk() {
  convert_disk ${disk_filename} $(pwd) vmdk
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
