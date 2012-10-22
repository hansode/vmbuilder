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
  cp -p /etc/sysconfig/selinux ${chroot_dir}/etc/sysconfig/
}

function tearDown() {
  rm -rf ${chroot_dir}
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
