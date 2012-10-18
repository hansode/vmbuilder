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
  rm -f ${chroot_dir}
}

function test_trap_distro() {
  trap_distro ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
