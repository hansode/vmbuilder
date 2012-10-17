#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare rootsize=8
declare swapsize=8
declare optsize=8
declare totalsize=$((${rootsize} + ${swapsize} + ${optsize}))

## public functions

function setUp() {
  mkdisk ${disk_filename} ${totalsize} 2>/dev/null
  parted --script ${disk_filename} mklabel msdos
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_mkpart() {
  mkpart ${disk_filename} primary 0 ${totalsize} ext2
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
