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
  mkdir -p ${chroot_dir}/etc
  function chroot() { echo chroot $*; }
  function prevent_udev_starting() { echo prevent_udev_starting $*; }
  function reconfigure_fstab() { echo reconfigure_fstab $*; }
  function reconfigure_mtab() { echo reconfigure_mtab $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_container() {
  configure_container ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
