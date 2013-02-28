#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare username=vmbuilder

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc
  touch ${chroot_dir}/etc/sudoers

  function chroot() { echo chroot $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_sudo_sudoers_devel_sudoers() {
  configure_sudo_sudoers ${chroot_dir} ${username} >/dev/null
  assertEquals "$(egrep -w "^${username}" ${chroot_dir}/etc/sudoers)" "${username} ALL=(ALL) NOPASSWD: ALL"
}

## shunit2

. ${shunit2_file}
