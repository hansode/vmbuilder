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
  mkdisk ${disk_filename} $(sum_disksize)

  local tmpdir=/tmp/vmbuilder-grub
  mkdir -p ${chroot_dir}${tmpdir}
  touch ${chroot_dir}${tmpdir}/device.map

  function checkroot() { :; }
  function is_dev() { echo is_dev $*; }
}

function tearDown() {
  rm ${disk_filename}
  rm -rf ${chroot_dir}
}

function test_install_bootloader_cleanup() {
  install_bootloader_cleanup ${chroot_dir} ${disk_filename} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
