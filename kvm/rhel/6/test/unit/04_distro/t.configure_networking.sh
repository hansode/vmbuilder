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
  mkdir -p ${chroot_dir}/etc/sysconfig/
  mkdir -p ${chroot_dir}/etc/udev/rules.d

  function config_host_and_domainname() { echo config_host_and_domainname $* ; }
  function config_interfaces() { echo config_interfaces $* ; }
  function config_routing() { echo config_routing $* ; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_networking_exists_udev() {
  touch ${chroot_dir}/etc/udev/rules.d/70-persistent-net.rules

  configure_networking ${chroot_dir}
  assertEquals $? 0
}

function test_configure_networking_not_exist_udev() {
  configure_networking ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
