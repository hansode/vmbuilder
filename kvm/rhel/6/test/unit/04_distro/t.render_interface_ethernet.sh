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

### set value

function test_render_interface_ethernet_eth0() {
  render_interface_ethernet ${chroot_dir} eth0
  assertEquals $? 0
}

function test_render_interface_ethernet_eth0() {
  render_interface_ethernet ${chroot_dir} eth1
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
