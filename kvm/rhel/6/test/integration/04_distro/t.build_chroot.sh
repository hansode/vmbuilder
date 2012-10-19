#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_build_chroot_distro_name_default() {
  local distro_name=

  build_chroot ${chroot_dir}
  assertEquals $? 0
}

function test_build_chroot_distro_name_centos() {
  local distro_name=centos

  build_chroot ${chroot_dir}
  assertEquals $? 0
}

function test_build_chroot_distro_name_sl() {
  local distro_name=sl

  build_chroot ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
