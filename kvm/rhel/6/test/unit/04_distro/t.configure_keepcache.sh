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
  mkdir -p ${chroot_dir}/etc
  cp -p /etc/yum.conf ${chroot_dir}/etc
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_keepcache() {
  configure_keepcache ${chroot_dir} | egrep -q -w ^keepcache=1
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
