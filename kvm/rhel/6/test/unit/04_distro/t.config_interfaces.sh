#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare ifcfg_path=${chroot_dir}/etc/sysconfig/network-scripts/ifcfg-eth0

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

function test_config_interfaces_dhcp() {
  config_interfaces ${chroot_dir} >/dev/null
  . ${ifcfg_path}

  assertEquals "${DEVICE}"    "eth0"
  assertEquals "${TYPE}"      "Ethernet"
  assertEquals "${BOOTPROTO}" "dhcp"
  assertEquals "${ONBOOT}"    "yes"
  assertEquals "${IPADDR}"    ""
  assertEquals "${NETWORK}"   ""
  assertEquals "${NETMASK}"   ""
  assertEquals "${BROADCAST}" ""
  assertEquals "${MACADDR}"   ""
  assertEquals "${HWADDR}"    ""
}

### set value

function test_config_interfaces_static_ip() {
  local ip=192.0.2.10

  config_interfaces ${chroot_dir} >/dev/null
  . ${ifcfg_path}

  assertEquals "${DEVICE}"    "eth0"
  assertEquals "${TYPE}"      "Ethernet"
  assertEquals "${BOOTPROTO}" "static"
  assertEquals "${ONBOOT}"    "yes"
  assertEquals "${IPADDR}"    "${ip}"
  assertEquals "${NETWORK}"   ""
  assertEquals "${NETMASK}"   ""
  assertEquals "${BROADCAST}" ""
  assertEquals "${GATEWAY}"   ""
  assertEquals "${ONBOOT}"    "yes"
  assertEquals "${MACADDR}"   ""
  assertEquals "${HWADDR}"    ""
}

function test_config_interfaces_static_ip_net() {
  local ip=192.0.2.10 net=192.0.2.0

  config_interfaces ${chroot_dir} >/dev/null
  . ${ifcfg_path}

  assertEquals "${DEVICE}"    "eth0"
  assertEquals "${TYPE}"      "Ethernet"
  assertEquals "${BOOTPROTO}" "static"
  assertEquals "${ONBOOT}"    "yes"
  assertEquals "${IPADDR}"    "${ip}"
  assertEquals "${NETWORK}"   "${net}"
  assertEquals "${NETMASK}"   ""
  assertEquals "${BROADCAST}" ""
  assertEquals "${GATEWAY}"   ""
  assertEquals "${ONBOOT}"    "yes"
  assertEquals "${MACADDR}"   ""
  assertEquals "${HWADDR}"    ""
}

function test_config_interfaces_static_ip_net_mask() {
  local ip=192.0.2.10 net=192.0.2.0 mask=255.255.255.128

  config_interfaces ${chroot_dir} >/dev/null
  . ${ifcfg_path}

  assertEquals "${DEVICE}"    "eth0"
  assertEquals "${TYPE}"      "Ethernet"
  assertEquals "${BOOTPROTO}" "static"
  assertEquals "${ONBOOT}"    "yes"
  assertEquals "${IPADDR}"    "${ip}"
  assertEquals "${NETWORK}"   "${net}"
  assertEquals "${NETMASK}"   "${mask}"
  assertEquals "${BROADCAST}" ""
  assertEquals "${GATEWAY}"   ""
  assertEquals "${ONBOOT}"    "yes"
  assertEquals "${MACADDR}"   ""
  assertEquals "${HWADDR}"    ""
}

function test_config_interfaces_static_ip_net_mask_bcast() {
  local ip=192.0.2.10 net=192.0.2.0 mask=255.255.255.128 bcast=192.0.2.127

  config_interfaces ${chroot_dir} >/dev/null
  . ${ifcfg_path}

  assertEquals "${DEVICE}"    "eth0"
  assertEquals "${TYPE}"      "Ethernet"
  assertEquals "${BOOTPROTO}" "static"
  assertEquals "${ONBOOT}"    "yes"
  assertEquals "${IPADDR}"    "${ip}"
  assertEquals "${NETWORK}"   "${net}"
  assertEquals "${NETMASK}"   "${mask}"
  assertEquals "${BROADCAST}" "${bcast}"
  assertEquals "${GATEWAY}"   ""
  assertEquals "${ONBOOT}"    "yes"
  assertEquals "${MACADDR}"   ""
  assertEquals "${HWADDR}"    ""
}

function test_config_interfaces_static_ip_net_mask_bcast_gw() {
  local ip=192.0.2.10 net=192.0.2.0 mask=255.255.255.128 bcast=192.0.2.127 gw=192.0.2.1

  config_interfaces ${chroot_dir} >/dev/null
  . ${ifcfg_path}

  assertEquals "${DEVICE}"    "eth0"
  assertEquals "${TYPE}"      "Ethernet"
  assertEquals "${BOOTPROTO}" "static"
  assertEquals "${ONBOOT}"    "yes"
  assertEquals "${IPADDR}"    "${ip}"
  assertEquals "${NETWORK}"   "${net}"
  assertEquals "${NETMASK}"   "${mask}"
  assertEquals "${BROADCAST}" "${bcast}"
  assertEquals "${GATEWAY}"   "${gw}"
  assertEquals "${MACADDR}"   ""
  assertEquals "${HWADDR}"    ""
}

function test_config_interfaces_static_ip_net_mask_bcast_gw_onboot() {
  local ip=192.0.2.10 net=192.0.2.0 mask=255.255.255.128 bcast=192.0.2.127 gw=192.0.2.1 onboot=no

  config_interfaces ${chroot_dir} >/dev/null
  . ${ifcfg_path}

  assertEquals "${DEVICE}"    "eth0"
  assertEquals "${TYPE}"      "Ethernet"
  assertEquals "${BOOTPROTO}" "static"
  assertEquals "${ONBOOT}"    "${onboot}"
  assertEquals "${IPADDR}"    "${ip}"
  assertEquals "${NETWORK}"   "${net}"
  assertEquals "${NETMASK}"   "${mask}"
  assertEquals "${BROADCAST}" "${bcast}"
  assertEquals "${GATEWAY}"   "${gw}"
  assertEquals "${MACADDR}"   ""
  assertEquals "${HWADDR}"    ""
}

function test_config_interfaces_static_ip_net_mask_bcast_gw_onboot_dns() {
  local dns1=8.8.8.8 dns2=8.8.4.4
  local ip=192.0.2.10 net=192.0.2.0 mask=255.255.255.128 bcast=192.0.2.127 gw=192.0.2.1 onboot=no dns="${dns1} ${dns2}"

  config_interfaces ${chroot_dir} >/dev/null
  . ${ifcfg_path}

  assertEquals "${DEVICE}"    "eth0"
  assertEquals "${TYPE}"      "Ethernet"
  assertEquals "${BOOTPROTO}" "static"
  assertEquals "${ONBOOT}"    "${onboot}"
  assertEquals "${IPADDR}"    "${ip}"
  assertEquals "${NETWORK}"   "${net}"
  assertEquals "${NETMASK}"   "${mask}"
  assertEquals "${BROADCAST}" "${bcast}"
  assertEquals "${GATEWAY}"   "${gw}"
  assertEquals "${DNS1}"      "${dns1}"
  assertEquals "${DNS2}"      "${dns2}"
  assertEquals "${MACADDR}"   ""
  assertEquals "${HWADDR}"    ""
}

function test_config_interfaces_static_ip_mac_hw() {
  local ip=192.0.2.10
  local mac=aa:bb:cc:dd:ee:ff hw=00:11:22:33:44:55

  config_interfaces ${chroot_dir} >/dev/null
  . ${ifcfg_path}

  assertEquals "${DEVICE}"    "eth0"
  assertEquals "${TYPE}"      "Ethernet"
  assertEquals "${BOOTPROTO}" "static"
  assertEquals "${ONBOOT}"    "yes"
  assertEquals "${IPADDR}"    "${ip}"
  assertEquals "${NETWORK}"   ""
  assertEquals "${NETMASK}"   ""
  assertEquals "${BROADCAST}" ""
  assertEquals "${GATEWAY}"   ""
  assertEquals "${ONBOOT}"    "yes"
  assertEquals "${MACADDR}"   "${mac}"
  assertEquals "${HWADDR}"    "${hw}"
}

### set empty

function test_config_interfaces_ip_empty() {
  local ip=

  config_interfaces ${chroot_dir} >/dev/null
  . ${ifcfg_path}

  assertEquals "${IPADDR}"    "${ip}"
}

function test_config_interfaces_net_empty() {
  local net=

  config_interfaces ${chroot_dir} >/dev/null
  . ${ifcfg_path}

  assertEquals "${NETWORK}"   "${net}"
}

function test_config_interfaces_mask_empty() {
  local mask=

  config_interfaces ${chroot_dir} >/dev/null
  . ${ifcfg_path}

  assertEquals "${NETMASK}"   "${mask}"
}

function test_config_interfaces_bcast_empty() {
  local bcast=

  config_interfaces ${chroot_dir} >/dev/null
  . ${ifcfg_path}

  assertEquals "${BROADCAST}" "${bcast}"
}

function test_config_interfaces_gw_empty() {
  local gw=

  config_interfaces ${chroot_dir} >/dev/null
  . ${ifcfg_path}

  assertEquals "${GATEWAY}"   "${gw}"
}

function test_config_interfaces_onboot_empty() {
  local onboot=

  config_interfaces ${chroot_dir} >/dev/null
  . ${ifcfg_path}

  assertEquals "${ONBOOT}"    "yes"
}

## shunit2

. ${shunit2_file}
