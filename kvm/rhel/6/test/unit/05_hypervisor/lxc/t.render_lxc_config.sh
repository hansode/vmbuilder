#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  add_option_hypervisor_lxc
  mkdir ${rootfs_dir}

  function checkroot() { :; }
  function shlog() { echo $*; }
}

function tearDown() {
  rm -rf ${rootfs_dir}
}

function test_render_lxc_config() {
  render_lxc_config >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
