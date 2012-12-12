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
  mkdisk ${disk_filename} $(sum_disksize)
  mkdir -p ${chroot_dir}

  function install_menu_lst_grub()  { echo install_menu_lst_grub  $*; }
  function install_menu_lst_grub2() { echo install_menu_lst_grub2 $*; }
}

function tearDown() {
  rm -f ${disk_filename}
  rm -rf ${chroot_dir}
}

function test_install_menu_lst_grub_ver1() {
  local preferred_grub=grub

  install_menu_lst ${chroot_dir} ${disk_filename}
  assertEquals $? 0
}

function test_install_menu_lst_grub_ver2() {
  local preferred_grub=grub2

  install_menu_lst ${chroot_dir} ${disk_filename}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
