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
  mkdisk ${disk_filename} ${totalsize} 2>/dev/null
  mkptab ${disk_filename}
  mapptab ${disk_filename}
}

function tearDown() {
  unmapptab ${disk_filename}
  rm -f ${disk_filename}
}

function test_devname2index_root() {
  assertEquals "$(devname2index root)" 1
}

function test_devname2index_swap() {
  assertEquals "$(devname2index swap)" 2
}

function test_devname2index_opt() {
  assertEquals "$(devname2index /opt)" 3
}

function test_devname2index_undevined() {
  devname2index undefined
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
