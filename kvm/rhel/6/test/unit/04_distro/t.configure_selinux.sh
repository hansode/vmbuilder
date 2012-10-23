#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc/sysconfig
  cat <<-EOS > ${chroot_dir}/etc/sysconfig/selinux
	# This file controls the state of SELinux on the system.
	# SELINUX= can take one of these three values:
	#     enforcing - SELinux security policy is enforced.
	#     permissive - SELinux prints warnings instead of enforcing.
	#     disabled - No SELinux policy is loaded.
	SELINUX=enforcing
	# SELINUXTYPE= can take one of these two values:
	#     targeted - Targeted processes are protected,
	#     mls - Multi Level Security protection.
	SELINUXTYPE=targeted
EOS
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_selinux_file_not_found() {
  rm ${chroot_dir}/etc/sysconfig/selinux

  configure_selinux ${chroot_dir} ""
  assertEquals $? 0
}

function test_configure_selinux_empty() {
  configure_selinux ${chroot_dir} ""
  assertEquals $? 0
}

function test_configure_selinux_enforcing() {
  configure_selinux ${chroot_dir} enforcing
  assertEquals $? 0
}

function test_configure_selinux_permissive() {
  configure_selinux ${chroot_dir} permissive
  assertEquals $? 0
}

function test_configure_selinux_disabled() {
  configure_selinux ${chroot_dir} disabled
  assertEquals $? 0
}

function test_configure_selinux_unknown() {
  configure_selinux ${chroot_dir} unknown
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
