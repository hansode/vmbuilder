#!/bin/bash
#
# requires:
#  bash
#  cd, dirname
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

### re-initialize variables for this unit test

declare rootsize=0
declare swapsize=0
declare optsize=0
declare totalsize=$((${rootsize} + ${swapsize} + ${optsize}))

## public functions

function test_xptabinfo_all_zero() {
  assertEquals $(xptabinfo | wc -l) 0
}

function test_xptabinfo_rootsize() {
  local rootsize=1024

  xptabinfo | egrep -q "^root ${rootsize}"
  assertEquals $? 0
}

function test_xptabinfo_swapsize() {
  local swapsize=1024

  xptabinfo | egrep -q "^swap ${swapsize}"
  assertEquals $? 0
}

function test_xptabinfo_optsize() {
  local optsize=1024

  xptabinfo | egrep -q "^/opt ${optsize}"
  assertEquals $? 0
}

function test_xptabinfo_rootsize_swapsize_optsize() {
  local rootsize=1024
  local swapsize=1024
  local optsize=1024

  assertEquals $(xptabinfo | wc -l) 3
}

## shunit2

. ${shunit2_file}
