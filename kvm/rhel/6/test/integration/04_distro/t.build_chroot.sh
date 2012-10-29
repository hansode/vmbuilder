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

  (
    set -e
    build_chroot ${chroot_dir}
  )
  assertEquals $? 0
}

function test_build_chroot_distro_name_centos6() {
  local distro_name=centos
  local distro_ver=6

  (
    set -e
    build_chroot ${chroot_dir}
  )
  assertEquals $? 0
}

function test_build_chroot_distro_name_sl6() {
  local distro_name=sl
  local distro_ver=6

  (
    set -e
    build_chroot ${chroot_dir}
  )
  assertEquals $? 0
}

function test_build_chroot_distro_name_unknown() {
  local distro_name=unknown

  (
    set -e
    build_chroot ${chroot_dir}
  )
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
