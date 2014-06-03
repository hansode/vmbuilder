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
  mkdir -p ${chroot_dir}/etc/modprobe.d
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_bonding_conf_no_opts() {
  configure_bonding_conf 2>/dev/null
  assertNotEquals 0 ${?}
}

function test_configure_bonding_conf_opts() {
  configure_bonding_conf ${chroot_dir} bond0
  assertEquals 0 ${?}
  assertEquals "alias bond0 bonding" "$(< ${chroot_dir}/etc/modprobe.d/bonding.conf)"

  configure_bonding_conf ${chroot_dir} bond0
  assertEquals 0 ${?}
  assertEquals "alias bond0 bonding" "$(< ${chroot_dir}/etc/modprobe.d/bonding.conf)"
}

function test_configure_bonding_conf_opts_2nics() {
  configure_bonding_conf ${chroot_dir} bond0
  assertEquals 0 ${?}

  configure_bonding_conf ${chroot_dir} bond1
  assertEquals 0 ${?}

  assertEquals "alias bond0 bonding
alias bond1 bonding" "$(< ${chroot_dir}/etc/modprobe.d/bonding.conf)"
}

## shunit2

. ${shunit2_file}
