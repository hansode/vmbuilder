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
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_lsdevmap() {
  lsdevmap ${disk_filename}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
