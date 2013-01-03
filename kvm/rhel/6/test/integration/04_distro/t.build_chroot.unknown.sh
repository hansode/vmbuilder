#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

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
