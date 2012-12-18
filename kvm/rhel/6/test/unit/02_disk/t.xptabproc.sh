#!/bin/bash
#
# requires:
#  bash
#  cd, dirname
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function test_xptabproc() {
  local rootsize=1024
  local swapsize=1024
  local optsize=1024

  diff <(
  xptabproc << 'EOS'
    echo ${mountpoint} ${partsize}
EOS
  ) <(xptabinfo)
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
