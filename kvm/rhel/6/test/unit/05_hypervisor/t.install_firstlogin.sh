#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

declare firstscript=${abs_dirname}/_firstscript.$$

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc
  mkdir -p ${chroot_dir}/root

  date > ${firstscript}
  date > ${chroot_dir}/etc/bashrc
}

function tearDown() {
  rm -rf ${chroot_dir}
  rm -f  ${firstscript}
}

function test_install_firstlogin() {
  install_firstlogin ${chroot_dir} ${firstscript}
  assertEquals $? 0

  # compare file
  diff ${firstscript} ${chroot_dir}/root/firstlogin.sh
  assertEquals "$?" "0"
}

function test_install_firstlogin_file_backup() {
  install_firstlogin ${chroot_dir} ${firstscript}

  [[ -f "${chroot_dir}/etc/bashrc.orig" ]]
  assertEquals "$?" "0"
}

function test_install_firstlogin_file_master() {
  install_firstlogin ${chroot_dir} ${firstscript}

  [[ -e "${chroot_dir}/etc/bashrc" ]]
  assertEquals "$?" "0"
}

function test_install_firstlogin_file_firstloginsh() {
  install_firstlogin ${chroot_dir} ${firstscript}

  [[ -x "${chroot_dir}/root/firstlogin.sh" ]]
  assertEquals "$?" "0"
}

## shunit2

. ${shunit2_file}
