#!/bin/bash
#
# requires:
#  bash
#  dirname, pwd
#  mkdir, rm
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

declare chroot_dir=${abs_dirname}/_chroot.$$

## public functions

function setUp() {
  mkdir -p ${chroot_dir}

  function chroot() { echo chroot $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

test_shlog_available_command() {
  assertEquals \
   "`shlog echo hello`" \
        "\$ echo hello
hello"
}

test_shlog_unavailable_command() {
  assertNotEquals \
   "`shlog typo hello 2>/dev/null`" \
        "\$ typo hello
hello"
}

## shunit2

. ${shunit2_file}
