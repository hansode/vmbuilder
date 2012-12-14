#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

### nictab

function test_install_os_nictab() {
  local nictab=${abs_dirname}/../../../examples/nictab.txt.example

  (
    set -e
    install_os ${chroot_dir} ${distro_dir} ${disk_filename}
  )
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
