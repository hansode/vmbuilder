#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function test_install_os() {
  (
    set -e
    install_os ${chroot_dir} ${distro_dir} ${disk_filename}
  )
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
