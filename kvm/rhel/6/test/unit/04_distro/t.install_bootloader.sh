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
  mkdir -p ${chroot_dir}/tmp/vmbuilder-grub

  function checkroot() { :; }

  function is_dev() { echo is_dev $*; }
  function chroot() { echo chroot $*; }
  function grub() { cat; }
  function grub2-setup() { echo grub2-setup $*; }
  function install_menu_lst() { echo install_menu_lst $*; }

  function install_grub()  { echo install_grub  $*; }
  function install_grub2() { echo install_grub2 $*; }
}

function tearDown() {
  rm ${disk_filename}
  rm -rf ${chroot_dir}
}

function test_install_bootloader_grub_ver1() {
  preferred_grub=grub

  install_bootloader ${chroot_dir} ${disk_filename} >/dev/null
  assertEquals $? 0
}

function test_install_bootloader_grub_ver2() {
  preferred_grub=grub2

  install_bootloader ${chroot_dir} ${disk_filename} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
