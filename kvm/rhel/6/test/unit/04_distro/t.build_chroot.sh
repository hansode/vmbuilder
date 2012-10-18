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
  function checkroot() { echo checkroot; }
  function bootstrap() { echo bootstrap $*; }
  function install_kernel() { echo install_kernel $*; }
  function configure_os() { echo configure_os $*; }
  function cleanup_distro() { echo cleanup_distro $*; }
}

function test_build_chroot() {
  build_chroot ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
