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
  add_option_distro
}

function test_distroinfo() {
  distroinfo | egrep ^chroot_dir | egrep -q ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
