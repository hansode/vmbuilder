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
  checkroot || return 1
  mkfs $(mntpnt2path ${disk_filename} root)
  mkfs $(mntpnt2path ${disk_filename} swap)
  mkfs $(mntpnt2path ${disk_filename} /opt)
}

function tearDown() {
  unmapptab ${disk_filename}
  rm -f ${disk_filename}
}

function test_mntpntuuid_root() {
  mntpntuuid ${disk_filename} root
  assertEquals $? 0
}

function test_mntpntuuid_swap() {
  mntpntuuid ${disk_filename} swap
  assertEquals $? 0
}

function test_mntpntuuid_opt() {
  mntpntuuid ${disk_filename} /opt
  assertEquals $? 0
}

function test_mntpntuuid_empty() {
  mntpntuuid ${disk_filename}
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
