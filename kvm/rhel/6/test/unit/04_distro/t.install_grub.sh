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
  add_option_distro
  mkdir -p ${chroot_dir}/boot/grub
  for grub_distro_name in redhat unknown; do
    mkdir -p ${chroot_dir}/usr/share/grub/${basearch}-${grub_distro_name}
  done
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_install_grub() {
  install_grub ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
