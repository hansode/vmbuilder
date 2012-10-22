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
  mkdir -p ${chroot_dir}/proc
  mkdir -p ${chroot_dir}/dev

  function create_initial_user() { echo create_initial_user $*; }
  function prevent_daemons_starting() { echo prevent_daemons_starting $*; }
  function install_resolv_conf() { echo install_resolv_conf $*; }
  function install_extras() { echo install_extras $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_os() {
  configure_os ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
