#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  function run_yum() { echo run_yum $*; }

  mkdir -p ${chroot_dir}
  add_option_distro
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_install_grub2() {
  install_grub2 ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
