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
  touch ${disk_filename}
  mkdir -p ${chroot_dir}

  function checkroot() { :; }
  function umount_nonroot() { echo umount_nonroot $*; }
  function umount_root() { echo umount_nonroot $*; }
}

function tearDown() {
  rm -f ${disk_filename}
  rm -rf ${chroot_dir}
}

function test_umount_ptab() {
  umount_ptab ${chroot_dir} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
