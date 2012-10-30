#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_preferred_initrd_centos5() {
  local preferred_initrd=initrd

  assertEquals "$(preferred_initrd)" "${preferred_initrd}"
}

function test_preferred_initrd_centos6() {
  local preferred_initrd=initramfs

  assertEquals "$(preferred_initrd)" "${preferred_initrd}"
}


## shunit2

. ${shunit2_file}
