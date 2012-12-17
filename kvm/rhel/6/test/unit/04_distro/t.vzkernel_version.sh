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
  mkdir -p ${chroot_dir}

  function chroot() { echo chroot $*; }
  function rpm() { echo rpm $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_vzkernel_version() {
  vzkernel_version ${chroot_dir} | egrep vzkernel
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
