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
  mkdir -p ${chroot_dir}/etc
  cp -p /etc/yum.conf ${chroot_dir}/etc
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_keepcache_empty() {
  configure_keepcache ${chroot_dir} 1
  assertEquals $? 0
}

function test_configure_keepcache_0() {
  configure_keepcache ${chroot_dir} 0
  assertEquals $? 0
}

function test_configure_keepcache_1() {
  configure_keepcache ${chroot_dir} 1
  assertEquals $? 0
}

function test_configure_keepcache_2() {
  configure_keepcache ${chroot_dir} 2
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
