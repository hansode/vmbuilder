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
  function chroot() { echo chroot $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_mtab() {
  reconfigure_mtab ${chroot_dir} | egrep -q -w "ln -fs /proc/mounts /etc/mtab"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
