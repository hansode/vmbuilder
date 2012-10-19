#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdisk ${disk_filename} ${totalsize}
  mkdir -p ${chroot_dir}/boot/grub
  touch ${chroot_dir}/boot/vmlinuz-$$
  touch ${chroot_dir}/boot/initramfs-$$

  function mntpntuuid() { echo ASDF-ASDF-ASDF; }
}

function tearDown() {
  rm -f ${disk_filename}
  rm -rf ${chroot_dir}
}

function test_install_menu_lst() {
  install_menu_lst ${chroot_dir} ${disk_filename}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
