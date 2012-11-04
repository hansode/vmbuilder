#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

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
