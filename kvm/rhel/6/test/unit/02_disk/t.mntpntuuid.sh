#!/bin/bash
#
# requires:
#  bash
#  cd, dirname
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

declare part_filename=/dev/mapper/loop0p2

## public functions

function setUp() {
  touch ${disk_filename}

  function checkroot() { :; }
  function mntpnt2path() { echo ${part_filename}; }
  function blkid() { echo blkid $*; }
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_mntpntuuid_root() {
  mntpntuuid ${disk_filename} root | egrep ${part_filename}\$ -q
  assertEquals $? 0
}

function test_mntpntuuid_empty() {
  mntpntuuid ${disk_filename} 2>/dev/null
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
