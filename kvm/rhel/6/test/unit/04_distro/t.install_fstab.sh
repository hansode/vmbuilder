#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdisk ${disk_filename} $(sum_disksize)
  mkdir -p ${chroot_dir}/etc
  mkptab ${disk_filename}
  mapptab ${disk_filename}
}

function tearDown() {
  unmapptab ${disk_filename}
  rm ${disk_filename}
  rm -rf ${chroot_dir}
}

function test_install_fstab_ext3() {
  local preferred_filesystem=ext3

  install_fstab ${chroot_dir} ${disk_filename}
  assertEquals $? 0
}

function test_install_fstab_ext4() {
  local preferred_filesystem=ext4

  install_fstab ${chroot_dir} ${disk_filename}
  assertEquals $? 0
}


## shunit2

. ${shunit2_file}
