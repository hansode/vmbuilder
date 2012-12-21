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
  # MEMO: don't uncomment following line
  #assertNotEquals $? 0

  umount_ptab ${chroot_dir}
  unmapptab   ${disk_filename}

  false
}

## shunit2

### shunit2 hack
### call test function here in order to test/use trap
test_create_vm_not_enough_root

. ${shunit2_file}
