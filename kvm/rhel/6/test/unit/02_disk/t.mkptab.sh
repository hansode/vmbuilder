#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function tearDown() {
  rm -f ${disk_filename}
}

function test_mkptab_all_zero() {
  rootsize=0 swapsize=0 optsize=0
  totalsize=$((${rootsize} + ${swapsize} + ${optsize}))
  mkdisk ${disk_filename} ${totalsize}

  mkptab ${disk_filename}
  assertNotEquals $? 0
}

function test_mkptab_root() {
  rootsize=8 swapsize=0 optsize=0
  totalsize=$((${rootsize} + ${swapsize} + ${optsize}))
  mkdisk ${disk_filename} ${totalsize}

  mkptab ${disk_filename}
  assertEquals $? 0
}

function test_mkptab_root_swap() {
  rootsize=8 swapsize=8 optsize=0
  totalsize=$((${rootsize} + ${swapsize} + ${optsize}))
  mkdisk ${disk_filename} ${totalsize}

  mkptab ${disk_filename}
  assertEquals $? 0
}

function test_mkptab_root_swap() {
  rootsize=8 swapsize=8 optsize=8
  totalsize=$((${rootsize} + ${swapsize} + ${optsize}))
  mkdisk ${disk_filename} ${totalsize}

  mkptab ${disk_filename}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
