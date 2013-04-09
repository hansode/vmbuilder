#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function test_build_vif_opt_no_opts() {
  build_vif_opt | egrep -q -- '-netdev tap,ifname='
}

function test_build_vif_opt_set_vif_num() {
  local vif_num=3

  assertEquals "$(build_vif_opt | wc -l)" ${vif_num}
}

function test_build_vif_opt_defined_nic_driver_e1000() {
  local nic_driver=e1000
  build_vif_opt | egrep -q -- "-device ${nic_driver},"
  assertEquals $? 0
}

function test_build_vif_opt_defined_nic_driver_virtio() {
  local nic_driver=virtio-net-pci
  build_vif_opt | egrep -q -- "-device ${nic_driver},"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
