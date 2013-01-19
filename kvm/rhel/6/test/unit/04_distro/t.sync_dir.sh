#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare copy_dir=${abs_dirname}/copy.$$

## public functions

function setUp() {
  mkdir -p ${chroot_dir}
  mkdir -p ${copy_dir}
  function rsync() { echo rsync $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
  rm -rf ${copy_dir}
}

function test_sync_dir_found() {
  sync_dir ${chroot_dir} ${copy_dir} >/dev/null
  assertEquals $? 0
}

function test_sync_dir_not_found() {
  sync_dir ${chroot_dir} ${abs_dirname}/$$.$$ 2>/dev/null
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
