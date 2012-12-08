#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_viftabproc() {
  diff <(
  viftabproc << 'EOS'
    echo ${vif_name} ${macaddr} ${bridge_if}
EOS
  ) <(viftabinfo)
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
