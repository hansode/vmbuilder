#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

declare nictab_file=${abs_dirname}/nictab_file.$$

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc/sysconfig/network-scripts

  cat <<-EOS > ${nictab_file}
	ifname=eth0 ip=192.0.2.10 mask=255.255.255.0 net=192.0.2.0 bcast=192.0.2.255 gw=192.0.2.1
	ifname=eth1 ip=192.0.2.11 mask=255.255.255.0 net=192.0.2.0 bcast=192.0.2.255 gw=192.0.2.1
	ifname=eth2 ip=192.0.2.12 mask=255.255.255.0 net=192.0.2.0 bcast=192.0.2.255 gw=192.0.2.1
	ifname=eth3 ip=192.0.2.13 mask=255.255.255.0 net=192.0.2.0 bcast=192.0.2.255 gw=192.0.2.1
	ifname=eth4 ip=192.0.2.14 mask=255.255.255.0 net=192.0.2.0 bcast=192.0.2.255 gw=192.0.2.1
	ifname=eth5 ip=192.0.2.15 mask=255.255.255.0 net=192.0.2.0 bcast=192.0.2.255 gw=192.0.2.1
	EOS
}

function tearDown() {
  rm -rf ${chroot_dir}
  rm     ${nictab_file}
}

### set value

function test_config_interfaces_eth0() {
  nictab=${nictab_file}

  config_interfaces ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
