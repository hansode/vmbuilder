#!/bin/bash
#
# requires:
#  bash
#  pwd
#  date, egrep
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare chroot_dir=${abs_dirname}/_chroot.$$

## public functions

function setUp() {
  function cause_daemons_starting() { echo cause_daemons_starting $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_unprevent_daemons_starting() {
  unprevent_daemons_starting ${chroot_dir} asdf >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
