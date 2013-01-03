#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare nictab_file=${abs_dirname}/nictab_file.$$

## public functions

function setUp() {
  DEVICE= TYPE=
  BOOTPROTO= IPADDR= NETMASK= NETWORK= BROADCAST= GATEWAY=
  DNS1= DNS2= DNS3=
  ifname= ip= mask= net= bcast= gw= dns= onboot= iftype=

  mkdir -p ${chroot_dir}/etc/sysconfig/network-scripts

  cat <<-EOS > ${nictab_file}
	ifname=eth0 bridge=br0
	ifname=br0 ip=192.0.2.10 mask=255.255.255.0 net=192.0.2.0 bcast=192.0.2.255 gw=192.0.2.1 iftype=ovsbridge
	EOS
}

function tearDown() {
  rm -rf ${chroot_dir}
  rm     ${nictab_file}
}

### set value

function test_config_interfaces_ovsbridge_br0() {
  nictab=${nictab_file}

  local ifname=br0
  local ifcfg_path=${chroot_dir}/etc/sysconfig/network-scripts/ifcfg-${ifname}

  config_interfaces ${chroot_dir} >/dev/null
  . ${ifcfg_path}

  assertEquals "${DEVICE}"    "${ifname}"
  assertEquals "${TYPE}"      "OVSBridge"
  assertEquals "${BOOTPROTO}" "static"
  assertEquals "${ONBOOT}"    "yes"
  assertEquals "${IPADDR}"    "192.0.2.10"
  assertEquals "${NETWORK}"   "192.0.2.0"
  assertEquals "${NETMASK}"   "255.255.255.0"
  assertEquals "${BROADCAST}" "192.0.2.255"
  assertEquals "${GATEWAY}"   "192.0.2.1"
  assertEquals "${ONBOOT}"    "yes"
}

## shunit2

. ${shunit2_file}
