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
  mkdir -p ${chroot_dir}/etc/yum.repos.d/

  function curl() { echo curl $*; }
  function chroot() { echo chroot $*; }
  function run_yum() { echo run_yum $*; }
  function verify_kernel_installation() { echo verify_kernel_installation $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_install_vzkernel() {
  install_vzkernel ${chroot_dir} | egrep -q -w vzkernel
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
