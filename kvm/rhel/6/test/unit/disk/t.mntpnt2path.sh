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

function test_mntpnt2path_root() {
  mntpnt2path ${disk_filename} root
  assertEquals $? 0
}

function test_mntpnt2path_swap() {
  mntpnt2path ${disk_filename} swap
  assertEquals $? 0
}

function test_mntpnt2path_opt() {
  mntpnt2path ${disk_filename} /opt
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}