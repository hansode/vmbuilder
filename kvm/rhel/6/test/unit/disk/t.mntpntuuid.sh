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
  truncate -s ${totalsize}m ${disk_filename}
  # TODO: replace mkptab with low level commands
  mkptab ${disk_filename}
  kpartx -va ${disk_filename}
  mkfs $(mntpnt2path ${disk_filename} root)
  mkfs $(mntpnt2path ${disk_filename} swap)
  mkfs $(mntpnt2path ${disk_filename} /opt)
}

function tearDown() {
  kpartx -vd ${disk_filename}
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

## shunit2

. ${shunit2_file}
