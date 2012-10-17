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
  add_option_distro
}

function test_distroinfo() {
  distroinfo | egrep ^chroot_dir | egrep -q ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
