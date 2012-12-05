#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare firstscript=${abs_dirname}/_firstscript.$$

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc/rc.d
  mkdir -p ${chroot_dir}/root

  date > ${firstscript}
  date > ${chroot_dir}/etc/rc.d/rc.local
}

function tearDown() {
  rm -rf ${chroot_dir}
  rm -f  ${firstscript}
}

function test_install_firstboot() {
  install_firstboot ${chroot_dir} ${firstscript}
  assertEquals $? 0

  # compare file
  diff ${firstscript} ${chroot_dir}/root/firstboot.sh
  assertEquals "$?" "0"
}

function test_install_firstboot_file_backup() {
  install_firstboot ${chroot_dir} ${firstscript}

  [[ -f "${chroot_dir}/etc/rc.d/rc.local.orig" ]]
  assertEquals "$?" "0"
}

function test_install_firstboot_file_master() {
  install_firstboot ${chroot_dir} ${firstscript}

  [[ -x "${chroot_dir}/etc/rc.d/rc.local" ]]
  assertEquals "$?" "0"
}

function test_install_firstboot_file_firstbootsh() {
  install_firstboot ${chroot_dir} ${firstscript}

  [[ -x "${chroot_dir}/root/firstboot.sh" ]]
  assertEquals "$?" "0"
}

## shunit2

. ${shunit2_file}
