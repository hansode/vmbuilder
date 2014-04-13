#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc/sysconfig/network-scripts

  DEVICE= TYPE=
  BOOTPROTO= IPADDR= NETMASK= NETWORK= BROADCAST= GATEWAY=
  DNS1= DNS2= DNS3=
  ifname= ip= mask= net= bcast= gw= dns= onboot= iftype=
  mac= hw=
}

function tearDown() {
  rm -rf ${chroot_dir}
}

### set value

function test_render_interface_network_configuration_no_opts() {
  eval "$(render_interface_network_configuration)"
  assertEquals "${BOOTPROTO}" "dhcp"
}

function test_render_interface_network_configuration_ip() {
  local ip=192.0.2.1

  eval "$(render_interface_network_configuration)"
  assertEquals "${IPADDR}" "${ip}"
}

function test_render_interface_network_configuration_onboot() {
  local onboot=no

  eval "$(render_interface_network_configuration)"
  assertEquals "${ONBOOT}" "${onboot}"
}

function test_render_interface_network_configuration_dnses() {
  local dns1=8.8.8.8 dns2=8.8.4.4
  local dns="${dns1} ${dns2}"

  eval "$(render_interface_network_configuration)"
  assertEquals "${DNS1}" "${dns1}"
  assertEquals "${DNS2}" "${dns2}"
}

## shunit2

. ${shunit2_file}
