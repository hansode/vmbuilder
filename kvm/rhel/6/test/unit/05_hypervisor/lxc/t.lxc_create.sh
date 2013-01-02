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
  rm -f ${abs_dirname}/lxc.conf
  rm -rf ${rootfs_dir}
}

function test_lxc_create() {
  local name=vmbuilder

  lxc_create ${name} | egrep -q -w "lxc-create -f ${abs_dirname}/lxc.conf -n ${name}"
}

## shunit2

. ${shunit2_file}
