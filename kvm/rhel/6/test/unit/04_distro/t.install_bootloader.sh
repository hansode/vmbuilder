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
  mkdir -p ${chroot_dir}/tmp/vmbuilder-grub
  function is_dev() { echo is_dev $*; }
  function chroot() { echo chroot $*; }
  function grub() { cat; }
  function install_menu_lst() { echo install_menu_lst $*; }
}

function tearDown() {
  rm ${disk_filename}
  rm -rf ${chroot_dir}
}

function test_install_bootloader() {
  install_bootloader ${chroot_dir} ${disk_filename}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
