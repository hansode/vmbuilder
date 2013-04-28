#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

### re-initialize variables for this unit test

## public functions

function test_nictabinfo_all_zero() {
  assertEquals "$(nictabinfo | egrep -w "^ifname=eth0 ip= mask= net= bcast= gw= dns=\"\" onboot= iftype=ethernet")" "ifname=eth0 ip= mask= net= bcast= gw= dns=\"\" onboot= iftype=ethernet"
}

function test_nictabinfo_ifname_eth0() {
  local ifname=eth0

  assertEquals "$(nictabinfo | egrep -w "^ifname=${ifname} ip= mask= net= bcast= gw= dns=\"\" onboot= iftype=ethernet")" "ifname=${ifname} ip= mask= net= bcast= gw= dns=\"\" onboot= iftype=ethernet"
}

function test_nictabinfo_ifname_eth1() {
  # ifname is always eth0
  local ifname=eth1

  assertNotEquals "$(nictabinfo | egrep -w "^ifname=${ifname} ip= mask= net= bcast= gw=")" "ifname=${ifname} ip= mask= net= bcast= gw="
}

function test_nictabinfo_set_args() {
  local ifname=eth0
  local ip=192.0.2.10
  local mask=255.255.255.0
  local net=192.0.2.0
  local bcast=192.0.2.255
  local gw=192.0.2.1
  local dns=8.8.4.4

  assertEquals "$(nictabinfo | egrep -w "^ifname=${ifname} ip=${ip} mask=${mask} net=${net} bcast=${bcast} gw=${gw} dns=\"${dns}\" onboot= iftype=ethernet")" "ifname=${ifname} ip=${ip} mask=${mask} net=${net} bcast=${bcast} gw=${gw} dns=\"${dns}\" onboot= iftype=ethernet"
}

function test_nictabinfo_set_args_multi_line_dns() {
  local ifname=eth0
  local ip=192.0.2.10
  local mask=255.255.255.0
  local net=192.0.2.0
  local bcast=192.0.2.255
  local gw=192.0.2.1
  local dns="
 8.8.4.4
 8.8.8.8
"

  assertEquals "$(nictabinfo | egrep -w "^ifname=${ifname} ip=${ip} mask=${mask} net=${net} bcast=${bcast} gw=${gw} dns=\"$(echo ${dns})\" onboot= iftype=ethernet")" "ifname=${ifname} ip=${ip} mask=${mask} net=${net} bcast=${bcast} gw=${gw} dns=\"$(echo ${dns})\" onboot= iftype=ethernet"
}

## shunit2

. ${shunit2_file}
