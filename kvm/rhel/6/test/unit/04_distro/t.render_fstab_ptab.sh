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
  mkdir -p ${chroot_dir}/etc
  mkdisk   ${disk_filename} $(sum_disksize)
  mkptab   ${disk_filename}
  mapptab  ${disk_filename}
  mkfsdisk ${disk_filename} $(preferred_filesystem)
}

function tearDown() {
  unmapptab ${disk_filename}
  rm -f     ${disk_filename}
  rm -rf    ${chroot_dir}
}

function test_render_fstab_ptab_ext3() {
  local preferred_filesystem=ext3

  render_fstab_ptab ${chroot_dir} ${disk_filename}
  assertEquals $? 0
}

function test_render_fstab_ptab_ext4() {
  local preferred_filesystem=ext4

  render_fstab_ptab ${chroot_dir} ${disk_filename}
  assertEquals $? 0
}

## fstab_type

function test_render_fstab_ptab_type_undefined() {
  local fstab_type=

  render_fstab_ptab ${chroot_dir} ${disk_filename}
  assertEquals $? 0
}

function test_render_fstab_ptab_type_uuid() {
  local fstab_type=uuid

  render_fstab_ptab ${chroot_dir} ${disk_filename}
  assertEquals $? 0
}

function test_render_fstab_ptab_type_label() {
  local fstab_type=label

  render_fstab_ptab ${chroot_dir} ${disk_filename}
  assertEquals $? 0
}

function test_render_fstab_ptab_type_unknown() {
  local fstab_type=unknown

  render_fstab_ptab ${chroot_dir} ${disk_filename}
  assertNotEquals $? 0
}



## shunit2

. ${shunit2_file}
