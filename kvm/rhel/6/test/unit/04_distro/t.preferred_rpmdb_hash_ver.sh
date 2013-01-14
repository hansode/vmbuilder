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
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_preferred_rpmdb_hash_ver() {
  preferred_rpmdb_hash_ver ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
