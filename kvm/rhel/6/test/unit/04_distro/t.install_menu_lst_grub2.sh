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
  mkdir -p ${chroot_dir}/boot/grub2
  touch    ${chroot_dir}/boot/grub2/grub.cfg

  function chroot() { echo chroot $*; }
  function mangle_grub_menu_lst_grub2() { echo mangle_grub_menu_lst_grub2 $*; }
}

function tearDown() {
  rm -f  ${disk_filename}
  rm -rf ${chroot_dir}
}

function test_install_menu_lst_grub2() {
  install_menu_lst_grub2 ${chroot_dir} ${disk_filename}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
