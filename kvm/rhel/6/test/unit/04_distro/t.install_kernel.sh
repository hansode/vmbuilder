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
  mkdir -p ${chroot_dir}/boot
  touch    ${chroot_dir}/boot/initrd-asdf
  touch    ${chroot_dir}/boot/initramfs-asdf
  touch    ${chroot_dir}/boot/vmlinuz-asdf

  function run_yum() { echo run_yum $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_install_kernel() {
  install_kernel ${chroot_dir} | egrep -q kernel
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
