#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare routetab_file=${abs_dirname}/routetab.$$

### re-initialize variables for this unit test

## public functions

function setUp() {
  mkdir -p ${chroot_dir}

  cat <<EOS > ${routetab_file}
# eth0
ifname=eth0 net=10.0.2.0 mask=255.255.255.0   gw=10.0.2.254
ifname=eth0 net=10.0.3.0 mask=255.255.255.128 gw=10.0.3.254

# eth1
ifname=eth1 net=10.1.4.0 mask=255.255.255.192 gw=10.1.4.254

# eth2
ifname=eth2 net=10.2.5.0 mask=255.255.0.0 gw=10.0.5.1
EOS

  function install_routing() { echo install_routing $*; }
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
