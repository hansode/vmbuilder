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
  mkdir -p ${chroot_dir}

  function install_vzkernel() { echo install_vzkernel $*; }
  function install_vzutils() { echo install_vzutils $*; }
  function install_menu_lst_vzkernel() { echo install_menu_lst_vzkernel $*; }
  function configure_vzconf() { echo configure_vzconf $@; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_openvz() {
  configure_openvz ${chroot_dir} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
