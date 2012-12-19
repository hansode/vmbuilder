#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

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

### set value

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

function test_config_interfaces_static_ip_net_mask_bcast_gw_onboot() {
  local ip=192.0.2.10 net=192.0.2.0 mask=255.255.255.128 bcast=192.0.2.127 gw=192.0.2.1 onboot=no

  config_interfaces ${chroot_dir}
  assertEquals $? 0
}

### set empty

function test_config_interfaces_ip_empty() {
  local ip=

  config_interfaces ${chroot_dir}
  assertEquals $? 0
}

function test_config_interfaces_net_empty() {
  local net=

  config_interfaces ${chroot_dir}
  assertEquals $? 0
}

function test_config_interfaces_mask_empty() {
  local mask=

  config_interfaces ${chroot_dir}
  assertEquals $? 0
}

function test_config_interfaces_bcast_empty() {
  local bcast=

  config_interfaces ${chroot_dir}
  assertEquals $? 0
}

function test_config_interfaces_gw_empty() {
  local gw=

  config_interfaces ${chroot_dir}
  assertEquals $? 0
}

function test_config_interfaces_onboot_empty() {
  local onboot=

  config_interfaces ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
