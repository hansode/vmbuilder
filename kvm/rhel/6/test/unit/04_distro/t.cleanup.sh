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
  mkdir -p ${chroot_dir}/var/log
  mkdir -p ${chroot_dir}/tmp
  touch ${chroot_dir}/var/log/asdf
  touch ${chroot_dir}/tmp/qwer
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_cleanup() {
  cleanup ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
