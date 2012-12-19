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
  mkdir -p ${chroot_dir}

  function chroot() { echo chroot $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}


function test_prevent_daemons_starting() {
  prevent_daemons_starting ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
