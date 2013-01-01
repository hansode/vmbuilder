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
  mkdir -p ${chroot_dir}/boot/grub
  touch ${chroot_dir}/boot/vmlinuz-$$
  touch ${chroot_dir}/boot/initramfs-$$

  function mntpntuuid() { echo ASDF-ASDF-ASDF; }
  function chroot() { echo chroot $*; }
}

function tearDown() {
  rm -f  ${disk_filename}
  rm -rf ${chroot_dir}
}

function test_install_menu_lst_grub() {
  install_menu_lst_grub ${chroot_dir} ${disk_filename} >/dev/null

  [[ -f ${chroot_dir}/boot/grub/grub.conf ]]
  assertEquals $? 0
}

## fstab_type

function test_install_menu_lst_grub_fstab_undefined() {
  local fstab_type=
  install_menu_lst_grub ${chroot_dir} ${disk_filename} >/dev/null

  [[ -f ${chroot_dir}/boot/grub/grub.conf ]]
  assertEquals $? 0
}

function test_install_menu_lst_grub_fstab_uuid() {
  local fstab_type=uuid
  install_menu_lst_grub ${chroot_dir} ${disk_filename} >/dev/null

  [[ -f ${chroot_dir}/boot/grub/grub.conf ]]
  assertEquals $? 0
}

function test_install_menu_lst_grub_fstab_label() {
  local fstab_type=label
  install_menu_lst_grub ${chroot_dir} ${disk_filename} >/dev/null

  [[ -f ${chroot_dir}/boot/grub/grub.conf ]]
  assertEquals $? 0
}

function test_install_menu_lst_grub_fstab_unknown() {
  local fstab_type=unknown
  install_menu_lst_grub ${chroot_dir} ${disk_filename} >/dev/null 2>&1

  [[ -f ${chroot_dir}/boot/grub/grub.conf ]]
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
