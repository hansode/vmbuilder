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

function test_distroinfo() {
  distroinfo | egrep ^chroot_dir | egrep -q -w ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
