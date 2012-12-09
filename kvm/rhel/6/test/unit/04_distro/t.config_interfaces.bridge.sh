#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare nictab_file=${abs_dirname}/nictab_file.$$

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc/sysconfig/network-scripts

  cat <<-EOS > ${nictab_file}
	ifname=eth0 bridge=br0
	ifname=br0 ip=192.0.2.10 mask=255.255.255.0 net=192.0.2.0 bcast=192.0.2.255 gw=192.0.2.1 iftype=bridge
	EOS

  function run_yum() { echo run_yum $*; }
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
