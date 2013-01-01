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
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_acpiphp() {
  configure_acpiphp ${chroot_dir} >/dev/null

  egrep -q -w "^acpiphp" ${chroot_dir}/etc/modules
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
