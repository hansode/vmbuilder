#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

declare chroot_dir=${abs_dirname}/chroot_dir.$$

## public functions

function setUp() {
  mkdir ${chroot_dir}

  function chroot() { echo chroot $*; }
  function prevent_udev_starting() { echo prevent_udev_starting $*; }
  function reconfigure_fstab() { echo reconfigure_fstab $*; }
  function reconfigure_mtab() { echo reconfigure_mtab $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_hypervisor() {
  configure_hypervisor ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
