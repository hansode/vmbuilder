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
  mkdir -p ${chroot_dir}/etc/sysconfig/

  touch ${chroot_dir}/etc/securetty
  echo 'ACTIVE_CONSOLES=/dev/tty[1-6]' > ${chroot_dir}/etc/sysconfig/init
}

function tearDown() {
  cat ${chroot_dir}/etc/securetty
  cat ${chroot_dir}/etc/sysconfig/init

  rm -rf ${chroot_dir}
}

function test_configure_console() {
  configure_console ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
