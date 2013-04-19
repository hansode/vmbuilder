#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare everyscript=${abs_dirname}/_everyscript.$$

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc/rc.d
  mkdir -p ${chroot_dir}/root

  date > ${everyscript}
  date > ${chroot_dir}/etc/rc.d/rc.local
}

function tearDown() {
  rm -rf ${chroot_dir}
  rm -f  ${everyscript}
}

function test_install_everyboot() {
  install_everyboot ${chroot_dir} ${everyscript} >/dev/null
  assertEquals $? 0

  # compare file
  diff ${everyscript} ${chroot_dir}/root/everyboot.sh
  assertEquals "$?" "0"
}

function test_install_everyboot_file_backup() {
  install_everyboot ${chroot_dir} ${everyscript} >/dev/null

  [[ -f "${chroot_dir}/etc/rc.d/rc.local.orig" ]]
  assertEquals "$?" "0"
}

function test_install_everyboot_file_master() {
  install_everyboot ${chroot_dir} ${everyscript} >/dev/null

  [[ -x "${chroot_dir}/etc/rc.d/rc.local" ]]
  assertEquals "$?" "0"
}

function test_install_everyboot_file_everybootsh() {
  install_everyboot ${chroot_dir} ${everyscript} >/dev/null

  [[ -x "${chroot_dir}/root/everyboot.sh" ]]
  assertEquals "$?" "0"
}

## shunit2

. ${shunit2_file}
