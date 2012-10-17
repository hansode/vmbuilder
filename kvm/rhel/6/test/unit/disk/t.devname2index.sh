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
}

function tearDown() {
  kpartx -vd ${disk_filename}
  rm -f ${disk_filename}
}

function test_devname2index_root() {
  devname2index ${disk_filename} root
  assertEquals $? 0
}

function test_devname2index_swap() {
  devname2index ${disk_filename} swap
  assertEquals $? 0
}

function test_devname2index_opt() {
  devname2index ${disk_filename} opt
  assertEquals $? 0
}


## shunit2

. ${shunit2_file}
