#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_build_chroot_distro_name_centos4() {
  local distro_name=centos
  local distro_ver=4

  (
    set -e
    build_chroot ${chroot_dir}
  )
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}