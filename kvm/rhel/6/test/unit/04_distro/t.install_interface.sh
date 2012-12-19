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
  function run_yum() { echo run_yum $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

### set value

## ethernet

function test_install_interface_ethernet_eth0_dhcp() {
  install_interface ${chroot_dir} eth0
  assertEquals $? 0
}

function test_install_interface_ethernet_eth0_ip() {
  local ip=192.0.2.10
  install_interface ${chroot_dir} eth0
  assertEquals $? 0
}

function test_install_interface_ethernet_eth1_dhcp() {
  install_interface ${chroot_dir} eth1
  assertEquals $? 0
}

function test_install_interface_ethernet_eth1_ip() {
  local ip=192.0.2.10
  install_interface ${chroot_dir} eth1
  assertEquals $? 0
}

## bridge

function test_install_interface_bridge_br0_dhcp() {
  install_interface ${chroot_dir} br0 bridge
  assertEquals $? 0
}

function test_install_interface_bridge_br0_ip() {
  local ip=192.0.2.10
  install_interface ${chroot_dir} br0 bridge
  assertEquals $? 0
}

## ovsbridge

function test_install_interface_ovsbridge_br0_dhcp() {
  install_interface ${chroot_dir} br0 ovsbridge
  assertEquals $? 0
}

function test_install_interface_ovsbridge_br0_ip() {
  local ip=192.0.2.10
  install_interface ${chroot_dir} br0 ovsbridge
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
