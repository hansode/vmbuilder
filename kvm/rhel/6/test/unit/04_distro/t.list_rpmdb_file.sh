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
  mkdir -p ${chroot_dir}/var/lib/rpm/
  touch    ${chroot_dir}/var/lib/rpm/sample

  function file() { echo "Berkeley DB"; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_list_rpmdb_file() {
  assertEquals "$(list_rpmdb_file ${chroot_dir})" "${chroot_dir}/var/lib/rpm/sample"
}

## shunit2

. ${shunit2_file}
