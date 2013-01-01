#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc
  mkdir -p ${chroot_dir}/etc/rc.d

  echo  /sbin/start_udev > ${chroot_dir}/etc/rc.sysinit
  echo  /sbin/start_udev > ${chroot_dir}/etc/rc.d/rc.sysinit

  function chroot() { echo chroot $*; }
}

function tearDown() {
  egrep -q -w "#/sbin/start_udev" ${chroot_dir}/etc/rc.sysinit
  egrep -q -w "#/sbin/start_udev" ${chroot_dir}/etc/rc.d/rc.sysinit

  rm -rf ${chroot_dir}
}


function test_prevent_udev_starting() {
  prevent_udev_starting ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
