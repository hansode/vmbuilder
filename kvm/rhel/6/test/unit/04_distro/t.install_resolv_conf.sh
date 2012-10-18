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
  mkdir -p ${chroot_dir}/etc/sysconfig
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_install_resolv_conf() {
  install_resolv_conf ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
