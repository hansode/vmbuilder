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
  mkdir -p ${chroot_dir}/etc/sysconfig

  function install_resolv_conf() { echo install_resolv_conf $*; }
  function config_host_and_domainname() { echo config_host_and_domainname $* ; }
  function config_interfaces() { echo config_interfaces $* ; }
  function config_routing() { echo config_routing $* ; }
  function config_udev_persistent_net() { echo config_udev_persistent_net $*; }
  function config_udev_persistent_net_generator() { echo config_udev_persistent_net_generator $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_networking() {
  configure_networking ${chroot_dir} >/dev/null

  [[ -f ${chroot_dir}/etc/sysconfig/network ]]
  assertEquals $? 0

  egrep -q -w ^NETWORKING=yes ${chroot_dir}/etc/sysconfig/network
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
