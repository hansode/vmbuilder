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

  function run_yum() { echo run_yum $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_install_extras() {
  install_extras ${chroot_dir} | egrep -q -w "openssh openssh-clients openssh-server rpm yum curl dhclient passwd vim-minimal yum"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
