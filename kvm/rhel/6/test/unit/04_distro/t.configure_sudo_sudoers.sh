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

function test_configure_sudo_sudoers_no_tag_specs() {
  configure_sudo_sudoers ${chroot_dir} ${username} >/dev/null
  assertEquals "$(egrep -w "^${username}" ${chroot_dir}/etc/sudoers)" "${username} ALL=(ALL) NOPASSWD: ALL"
}

function test_configure_sudo_sudoers_with_tag_spec() {
  local tag_specs="PASSWD:"
  configure_sudo_sudoers ${chroot_dir} ${username} ${tag_specs} >/dev/null
  assertEquals "$(egrep -w "^${username}" ${chroot_dir}/etc/sudoers)" "${username} ALL=(ALL) ${tag_specs} ALL"
}

function test_configure_sudo_sudoers_with_tag_specs() {
  local tag_specs="PASSWD: EXEC:"
  configure_sudo_sudoers ${chroot_dir} ${username} "PASSWD: EXEC:" >/dev/null
  assertEquals "$(egrep -w "^${username}" ${chroot_dir}/etc/sudoers)" "${username} ALL=(ALL) ${tag_specs} ALL"
}

## shunit2

. ${shunit2_file}
