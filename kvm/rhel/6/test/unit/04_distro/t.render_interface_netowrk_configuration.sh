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

function test_render_interface_netowrk_configuration_no_opts() {
  render_interface_netowrk_configuration
  assertEquals $? 0
}

function test_render_interface_netowrk_configuration_ip() {
  local ip=192.0.2.1

  render_interface_netowrk_configuration
  assertEquals $? 0
}

function test_render_interface_netowrk_configuration_onboot() {
  local onboot=no

  render_interface_netowrk_configuration | egrep ^ONBOOT=${onboot}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
