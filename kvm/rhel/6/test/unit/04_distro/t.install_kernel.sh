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
  mkdir -p ${chroot_dir}

  function run_yum() { echo run_yum $*; }
  function verify_kernel_installation() { echo verify_kernel_installation $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_install_kernel() {
  install_kernel ${chroot_dir} | egrep -q kernel
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
