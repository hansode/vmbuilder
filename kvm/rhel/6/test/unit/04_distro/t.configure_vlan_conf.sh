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

  touch ${chroot_dir}/etc/sysconfig/network
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_vlan_conf_no_opts() {
  configure_vlan_conf 2>/dev/null
  assertNotEquals 0 ${?}
}

function test_configure_vlan_conf_opts() {
  configure_vlan_conf ${chroot_dir}
  assertEquals 0 ${?}

  eval "$(< ${chroot_dir}/etc/sysconfig/network)"
  assertEquals yes                  "${VLAN}"
  assertEquals VLAN_PLUS_VID_NO_PAD "${VLAN_NAME_TYPE}"
}

## shunit2

. ${shunit2_file}
