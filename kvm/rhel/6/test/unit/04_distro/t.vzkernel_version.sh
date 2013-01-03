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
  mkdir -p ${chroot_dir}

  function chroot() { echo chroot $*; }
  function rpm() { echo rpm $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_vzkernel_version() {
  vzkernel_version ${chroot_dir} | egrep -q -w 'vzkernel$'
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
