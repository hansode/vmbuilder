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
  mkdir -p ${chroot_dir}/etc
  cat <<-EOS > ${chroot_dir}/etc/sudoers
	Defaults    requiretty
	EOS
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_sudo_requiretty_file_not_found() {
  rm ${chroot_dir}/etc/sudoers

  configure_sudo_requiretty ${chroot_dir} "" 2>/dev/null
  assertEquals $? 0
}

function test_configure_sudo_requiretty_empty() {
  configure_sudo_requiretty ${chroot_dir} "" >/dev/null

  egrep "^Defaults\s+requiretty" -q ${chroot_dir}/etc/sudoers
  assertEquals $? 0
}

function test_configure_sudo_requiretty_enabled() {
  configure_sudo_requiretty ${chroot_dir} 1 >/dev/null

  egrep "^Defaults\s+requiretty" -q ${chroot_dir}/etc/sudoers
  assertEquals $? 0
}

function test_configure_sudo_requiretty_disabled() {
  configure_sudo_requiretty ${chroot_dir} 0 >/dev/null

  egrep "^Defaults\s+requiretty" -q ${chroot_dir}/etc/sudoers
  assertNotEquals $? 0
}

function test_configure_sudo_requiretty_unknown() {
  configure_sudo_requiretty ${chroot_dir} 2 >/dev/null

  egrep "^Defaults\s+requiretty" -q ${chroot_dir}/etc/sudoers
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
