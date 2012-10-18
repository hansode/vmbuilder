#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc/sysconfig/network-scripts
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_config_interfaces_dhcp() {
  config_interfaces ${chroot_dir}
  assertEquals $? 0
}

function test_config_interfaces_static_ip() {
  local ip=192.0.2.10
  config_interfaces ${chroot_dir}
  assertEquals $? 0
}

function test_config_interfaces_static_ip_net() {
  local ip=192.0.2.10 net=192.0.2.0
  config_interfaces ${chroot_dir}
  assertEquals $? 0

}
function test_config_interfaces_static_ip_net_mask() {
  local ip=192.0.2.10 net=192.0.2.0 mask=255.255.255.128
  config_interfaces ${chroot_dir}
  assertEquals $? 0
}

function test_config_interfaces_static_ip_net_mask_bcast() {
  local ip=192.0.2.10 net=192.0.2.0 mask=255.255.255.128 bcast=192.0.2.127
  config_interfaces ${chroot_dir}
  assertEquals $? 0
}

function test_config_interfaces_static_ip_net_mask_bcast_gw() {
  local ip=192.0.2.10 net=192.0.2.0 mask=255.255.255.128 bcast=192.0.2.127 gw=192.0.2.1
  config_interfaces ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
