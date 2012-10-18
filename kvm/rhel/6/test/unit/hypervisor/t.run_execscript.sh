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
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_run_execscript() {
  run_execscript ${chroot_dir} /bin/echo
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
