#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

### root

function test_create_vm_not_enough_root() {
  local rootsize=650

  (
    set -e
    create_vm ${disk_filename} ${chroot_dir}
  )
}

## shunit2

. ${shunit2_file}
