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

  function run_yum() { echo run_yum "${@}"; }
  function run_in_target() { echo run_in_target "${@}"; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_clean_packages() {
  clean_packages ${chroot_dir} | egrep -q -w 'rpm -vv --rebuilddb'
  assertEquals 0 ${?}
}

## shunit2

. ${shunit2_file}
