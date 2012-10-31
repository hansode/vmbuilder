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

function test_build_chroot_distro_name_centos5() {
  local distro_name=centos
  local distro_ver=5

  (
    set -e
    build_chroot ${chroot_dir}
  )
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
