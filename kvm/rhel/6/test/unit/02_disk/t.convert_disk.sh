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
  touch ${disk_filename}

  function VBoxManage() { echo VBoxManage $*; }
  function qemu_img_path() { echo qemu_img_path $*; }
}

function tearDown() {
  rm -f ${disk_filename}
}

### no opts

function test_convert_disk_no_opts() {
  convert_disk 2>/dev/null
  assertNotEquals $? 0
}

### set opts

function test_convert_disk_filename() {
  convert_disk ${disk_filename} >/dev/null
}

function test_convert_disk_filename_destdir() {
  convert_disk ${disk_filename} ${PWD} >/dev/null
  assertEquals $? 0
}

function test_convert_disk_filename_destdir_destformat_vdi() {
  convert_disk ${disk_filename} ${PWD} vdi >/dev/null
  assertEquals $? 0
}

function test_convert_disk_filename_destdir_destformat_vmdk() {
  convert_disk ${disk_filename} ${PWD} vmdk >/dev/null
  assertEquals $? 0
}

function test_convert_disk_filename_destdir_destformat_qcow2() {
  convert_disk ${disk_filename} ${PWD} qcow2 >/dev/null
  assertEquals $? 0
}

function test_convert_disk_filename_destdir_destformat_unknown() {
  convert_disk ${disk_filename} ${PWD} unknown 2>/dev/null
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
