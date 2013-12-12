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
  mkdir -p ${chroot_dir}/usr/lib/systemd/system
  mkdir -p ${chroot_dir}/etc/systemd/system/getty.target.wants

  touch ${chroot_dir}/etc/inittab
  touch ${chroot_dir}/etc/securetty
  touch ${chroot_dir}/usr/lib/systemd/system/getty@.service
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_serial_console_rhel5() {
  echo 'CentOS release 5.9 (Final)' > ${chroot_dir}/etc/redhat-release
  configure_serial_console ${chroot_dir} >/dev/null
  egrep -q -w "^S0:2345:respawn:/sbin/agetty ttyS0 115200 linux" ${chroot_dir}/etc/inittab
  assertEquals 0 $?
}

function test_configure_serial_console_rhel6() {
  echo 'CentOS release 6.5 (Final)' > ${chroot_dir}/etc/redhat-release
  echo 'ACTIVE_CONSOLES=/dev/tty[1-6]' > ${chroot_dir}/etc/sysconfig/init
  configure_serial_console ${chroot_dir} >/dev/null
  egrep -w '^ACTIVE_CONSOLES=' ${chroot_dir}/etc/sysconfig/init | egrep -q -w '/dev/ttyS0'
  assertEquals 0 $?
}

function test_configure_serial_console_rhel7() {
  echo 'CentOS release 7.0 (Final)' > ${chroot_dir}/etc/redhat-release
  configure_serial_console ${chroot_dir} >/dev/null
  [[ -L ${chroot_dir}/etc/systemd/system/getty.target.wants/getty@ttyS0.service ]]
  assertEquals 0 $?
}

## shunit2

. ${shunit2_file}
