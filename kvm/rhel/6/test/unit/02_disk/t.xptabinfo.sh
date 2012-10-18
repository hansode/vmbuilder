#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

### re-initialize variables for this unit test

rootsize=0
swapsize=0
optsize=0
totalsize=$((${rootsize} + ${swapsize} + ${optsize}))

## public functions

function test_xptabinfo_all_zero() {
  assertEquals `xptabinfo | wc -l` 0
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
  assertEquals `xptabinfo | wc -l` 3
}

## shunit2

. ${shunit2_file}
