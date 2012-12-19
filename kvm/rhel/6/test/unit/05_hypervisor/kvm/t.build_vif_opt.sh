#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function test_build_vif_opt_no_opts() {
  build_vif_opt
  assertEquals $? 0
}

function test_build_vif_opt_set_vif_num() {
  local vif_num=3

  build_vif_opt ${vif_num}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
