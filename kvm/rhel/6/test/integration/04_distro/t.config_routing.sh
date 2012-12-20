#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

declare routetab_file=${abs_dirname}/routetab.$$

### re-initialize variables for this unit test

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc/sysconfig/network-scripts

  cat <<EOS > ${routetab_file}
# eth0
ifname=eth0 cidr=10.0.2.0/24 gw=10.0.2.254
ifname=eth0 cidr=10.0.3.0/25 gw=10.0.3.254

# eth1
ifname=eth1 cidr=10.1.4.0/26 gw=10.1.4.254

# eth2
ifname=eth2 cidr=10.2.5.0/16 gw=10.0.5.1
EOS
}

function tearDown() {
  rm -f ${routetab_file}
  rm -rf ${chroot_dir}
}

function test_config_routing() {
  local routetab=${routetab_file}
  config_routing ${chroot_dir}
}

## shunit2

. ${shunit2_file}
