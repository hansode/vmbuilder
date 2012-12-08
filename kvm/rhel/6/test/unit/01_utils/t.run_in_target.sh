#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare chroot_dir=${abs_dirname}/_chroot.$$

## public functions

function setUp() {
  mkdir -p ${chroot_dir}

  function chroot() { echo chroot $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_run_in_target() {
 run_in_target ${chroot_dir} date | egrep "chroot ${chroot_dir} bash -e -c date"
 assertEquals $? 0
}

## shunit2

. ${shunit2_file}
