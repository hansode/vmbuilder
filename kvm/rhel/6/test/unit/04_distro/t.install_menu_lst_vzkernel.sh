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
  mkdir -p ${chroot_dir}/boot/grub

  cat <<EOS > ${chroot_dir}/etc/fstab
/dev/mapper/VolGroup-lv_root / ext4 defaults 1 1
EOS

  cat <<EOS > ${chroot_dir}/boot/grub/grub.conf
default=3
EOS

  function vzkernel_version() { echo 2.6.32-042stab065.3; }
  function rpm() { echo rpm $*; }
  function chroot() { echo chroot $*; }
  function run_yum() { echo run_yum $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_install_menu_lst_vzkernel() {
  install_menu_lst_vzkernel ${chroot_dir}
  assertEquals $? 0

  egrep ^title ${chroot_dir}/boot/grub/grub.conf
  assertEquals $? 0

  egrep ^default= ${chroot_dir}/boot/grub/grub.conf
  assertEquals $? 0
}

function test_install_menu_lst_vzkernel_no_fstab() {
  # for diskless mode
  rm -f ${chroot_dir}/etc/fstab

  install_menu_lst_vzkernel ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
