#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

### re-initialize variables for this unit test

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc/sysconfig/network-scripts

  function render_routing() { echo render_routing $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_install_routing_empty() {
  install_routing ${chroot_dir} 2>/dev/null
  assertNotEquals $? 0
}

function test_install_routing_defined() {
  install_routing ${chroot_dir} eth0 >/dev/null

  [[ -f ${chroot_dir}/etc/sysconfig/network-scripts/route-eth0 ]]
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
