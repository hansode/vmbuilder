#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function test_build_chroot_distro_name_centos7() {
  local distro_name=centos
  local distro_ver=7

  (
    set -e
    build_chroot ${chroot_dir}
  )
  assertEquals 0 ${?}
}

## shunit2

. ${shunit2_file}
