#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

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
