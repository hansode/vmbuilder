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

  touch ${chroot_dir}/etc/securetty
  echo 'ACTIVE_CONSOLES=/dev/tty[1-6]' > ${chroot_dir}/etc/sysconfig/init
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_serial_console() {
  configure_serial_console ${chroot_dir} >/dev/null

  egrep -w '^ACTIVE_CONSOLES=' ${chroot_dir}/etc/sysconfig/init | egrep -q -w '/dev/ttyS0'
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
