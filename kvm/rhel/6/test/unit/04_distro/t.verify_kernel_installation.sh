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
  mkdir -p ${chroot_dir}/boot
  touch    ${chroot_dir}/boot/initrd-asdf
  touch    ${chroot_dir}/boot/initramfs-asdf
  touch    ${chroot_dir}/boot/vmlinuz-asdf
}

function tearDown() {
  rm -rf ${chroot_dir}
}

### exists

function test_verify_kernel_installation_exists_initrd() {
  local preferred_initrd=initrd

  verify_kernel_installation ${chroot_dir} >/dev/null
  assertEquals $? 0
}

function test_verify_kernel_installation_exists_initramfs() {
  local preferred_initrd=initramfs

  verify_kernel_installation ${chroot_dir} >/dev/null
  assertEquals $? 0
}

### not found

function test_verify_kernel_installation_not_found_initrd() {
  local preferred_initrd=initrd

  rm -f ${chroot_dir}/boot/initrd-asdf

  verify_kernel_installation ${chroot_dir} >/dev/null 2>&1
  assertNotEquals $? 0
}

function test_verify_kernel_installation_not_found_initramfs() {
  local preferred_initrd=initramfs

  rm -f ${chroot_dir}/boot/initramfs-asdf

  verify_kernel_installation ${chroot_dir} >/dev/null 2>&1
  assertNotEquals $? 0
}


## shunit2

. ${shunit2_file}
