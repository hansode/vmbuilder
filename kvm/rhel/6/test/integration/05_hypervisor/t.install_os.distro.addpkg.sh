#!/bin/bash
#
# requires:
#   bash
#   ssh-keygen
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

### variables

### functions

function test_install_os_distro_addpkg() {
  local addpkg="kpartx parted"

  (
    set -e
    install_os ${chroot_dir} ${distro_dir} ${disk_filename}
  )
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
