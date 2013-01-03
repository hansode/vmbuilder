#!/bin/bash
#
# requires:
#  bash
#  cd
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function tearDown() {
  rm -f ${disk_filename}
}

function test_mkptab_all_zero() {
  local rootsize=0 swapsize=0 optsize=0
  local totalsize=$((${rootsize} + ${swapsize} + ${optsize}))
  mkdisk ${disk_filename} $(sum_disksize)

  mkptab ${disk_filename}
  assertNotEquals $? 0
}

function test_mkptab_root() {
  local rootsize=8 swapsize=0 optsize=0
  local totalsize=$((${rootsize} + ${swapsize} + ${optsize}))
  mkdisk ${disk_filename} $(sum_disksize)

  mkptab ${disk_filename}
  assertEquals $? 0
}

function test_mkptab_root_swap() {
  local rootsize=8 swapsize=8 optsize=0
  local totalsize=$((${rootsize} + ${swapsize} + ${optsize}))
  mkdisk ${disk_filename} $(sum_disksize)

  mkptab ${disk_filename}
  assertEquals $? 0
}

function test_mkptab_root_swap_opt() {
  local rootsize=8 swapsize=8 optsize=8
  local totalsize=$((${rootsize} + ${swapsize} + ${optsize}))
  mkdisk ${disk_filename} $(sum_disksize)

  mkptab ${disk_filename}
  assertEquals $? 0
}

function test_mkptab_root_swap_opt_home_boot() {
  local rootsize=8 swapsize=8 optsize=8 homesize=8 bootsize=8
  local totalsize=$((${rootsize} + ${swapsize} + ${optsize} + ${homesize} + ${bootsize}))
  mkdisk ${disk_filename} $(sum_disksize)

  mkptab ${disk_filename}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
