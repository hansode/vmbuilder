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
  mkdir -p ${chroot_dir}/boot/grub2
  touch    ${chroot_dir}/boot/grub2/grub.cfg
  mkdir -p ${chroot_dir}/etc/default

  function chroot() { echo chroot $*; }
  function mangle_grub_menu_lst_grub2() { echo mangle_grub_menu_lst_grub2 $*; }
}

function tearDown() {
  rm -f  ${disk_filename}
  rm -rf ${chroot_dir}
}

function test_install_menu_lst_grub2() {
  install_menu_lst_grub2 ${chroot_dir} ${disk_filename} >/dev/null

  [[ -f ${chroot_dir}/etc/default/grub ]]
  assertEquals 0 $?

  [[ -f ${chroot_dir}/boot/grub2/grub.cfg ]]
  assertEquals 0 $?
}

## shunit2

. ${shunit2_file}
