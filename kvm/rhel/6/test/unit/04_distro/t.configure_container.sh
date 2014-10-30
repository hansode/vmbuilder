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
  function chroot() { echo chroot $*; }
  function mkdevice() { echo mkdevice $*; }
  function reconfigure_fstab() { echo reconfigure_fstab $*; }
  function reconfigure_mtab() { echo reconfigure_mtab $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_container() {
  configure_container ${chroot_dir} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
