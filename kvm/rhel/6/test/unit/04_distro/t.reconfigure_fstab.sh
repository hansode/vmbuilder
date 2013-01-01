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


function test_reconfigure_fstab() {
  reconfigure_fstab ${chroot_dir} >/dev/null

  [[ -f ${chroot_dir}/etc/fstab ]]
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
