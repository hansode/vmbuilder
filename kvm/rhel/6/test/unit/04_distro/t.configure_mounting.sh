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
  mkdisk ${disk_filename} ${totalsize}
  mkdir -p ${chroot_dir}/etc
}

function tearDown() {
  rm ${disk_filename}
  rm -rf ${chroot_dir}
}

function test_configure_mounting() {
  configure_mounting ${chroot_dir} ${disk_filename}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
