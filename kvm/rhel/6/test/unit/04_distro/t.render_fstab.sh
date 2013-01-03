#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc
  touch    ${disk_filename}

  function checkroot() { :; }
}

function tearDown() {
  rm -f     ${disk_filename}
  rm -rf    ${chroot_dir}
}

function test_render_fstab_ext3() {
  local preferred_filesystem=ext3

  render_fstab ${chroot_dir} ${disk_filename} | egrep -w / | egrep -q -w ${preferred_filesystem}
  assertEquals $? 0
}

function test_render_fstab_ext4() {
  local preferred_filesystem=ext4

  render_fstab ${chroot_dir} ${disk_filename} | egrep -w / | egrep -q -w ${preferred_filesystem}
  assertEquals $? 0
}

## fstab_type

function test_render_fstab_type_undefined() {
  local fstab_type=

  render_fstab ${chroot_dir} ${disk_filename} | egrep -w / | egrep -q -w ext3
  assertEquals $? 0
}

function test_render_fstab_type_uuid() {
  local fstab_type=uuid

  render_fstab ${chroot_dir} ${disk_filename} | egrep -w / | egrep -q ^UUID=
  assertEquals $? 0
}

function test_render_fstab_type_label() {
  local fstab_type=label

  render_fstab ${chroot_dir} ${disk_filename} | egrep -w / | egrep -q ^LABEL=
  assertEquals $? 0
}

function test_render_fstab_type_unknown() {
  local fstab_type=unknown

  render_fstab ${chroot_dir} ${disk_filename} >/dev/null 2>&1
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
