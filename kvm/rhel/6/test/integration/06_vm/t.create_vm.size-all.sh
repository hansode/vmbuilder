#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

### *size options

function test_create_vm_minimal_root_swap_opt_home_usr_var_tmp() {
  local rootsize=512 swapsize=4 optsize=4 bootsize=64 homesize=256 usrsize=384 varsize=256 tmpsize=256

  (
    set -e
    create_vm ${disk_filename} ${chroot_dir}
  )
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
