#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare distro_name=centos
declare distro_ver=6

## public functions

function setUp() {
  function checkroot() { echo checkroot; }
  function bootstrap() { echo bootstrap $*; }
  function configure_os() { echo configure_os $*; }
  function cleanup_distro() { echo cleanup_distro $*; }
}

function test_build_chroot_defined_chroot_dir() {
  build_chroot ${chroot_dir} >/dev/null
  assertEquals $? 0
}

function test_build_chroot_undefined_chroot_dir() {
  build_chroot >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
