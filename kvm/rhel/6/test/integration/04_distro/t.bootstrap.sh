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
  distro_name=centos
  distro_ver=6

  add_option_distro
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_bootstrap() {
  bootstrap ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
