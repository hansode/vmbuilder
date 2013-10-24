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
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_install_virtualbox() {
  install_virtualbox ${chroot_dir} | egrep -q -w VirtualBox-4.2
  assertEquals $? 0

  install_virtualbox ${chroot_dir} | egrep -q -w kernel-devel
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
