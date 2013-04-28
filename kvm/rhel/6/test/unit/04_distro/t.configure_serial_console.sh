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
  mkdir -p ${chroot_dir}/etc/sysconfig/

  touch ${chroot_dir}/etc/inittab
  touch ${chroot_dir}/etc/securetty
  echo 'ACTIVE_CONSOLES=/dev/tty[1-6]' > ${chroot_dir}/etc/sysconfig/init
  echo 'CentOS release 5.9 (Final)' > ${chroot_dir}/etc/redhat-release
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_serial_console() {
  configure_serial_console ${chroot_dir} >/dev/null

  egrep -w '^ACTIVE_CONSOLES=' ${chroot_dir}/etc/sysconfig/init | egrep -q -w '/dev/ttyS0'
  assertEquals $? 0
}

function test_configure_serial_console_rhel5() {
  configure_serial_console ${chroot_dir} >/dev/null
  egrep -q -w "^S0:2345:respawn:/sbin/agetty ttyS0 115200 linux" ${chroot_dir}/etc/inittab
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
