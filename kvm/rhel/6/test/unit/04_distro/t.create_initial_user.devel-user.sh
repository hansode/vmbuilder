#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare devel_user=vmbuilder
declare devel_group=${devel_user}
declare devel_home=/home/${devel_user}

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc
  mkdir -p ${chroot_dir}/${devel_home}

  touch ${chroot_dir}/${devel_home}/.bashrc

  function configure_sudo_sudoers() { echo configure_sudo_sudoers $*; }
  function chroot() { echo chroot $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_create_initial_user_devel() {
  create_initial_user ${chroot_dir} >/dev/null
  assertEquals $? 0
}

function test_create_initial_user_devel_getent_group() {
  create_initial_user ${chroot_dir} | egrep -q -w "getent group ${devel_group}"
  assertEquals $? 0
}

function test_create_initial_user_devel_getent_passwd() {
  create_initial_user ${chroot_dir} | egrep -q -w "getent passwd ${devel_user}"
  assertEquals $? 0
}

function test_create_initial_user_devel_umask() {
  create_initial_user ${chroot_dir} >/dev/null

  egrep -q -w "^umask 022" ${chroot_dir}/${devel_home}/.bashrc
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
