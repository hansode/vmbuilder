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
  mkdir -p ${chroot_dir}/etc/udev/rules.d
  touch ${chroot_dir}/etc/udev/rules.d/70-persistent-net.rules
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_config_udev_persistent_net_file_not_found() {
  rm ${chroot_dir}/etc/udev/rules.d/70-persistent-net.rules

  config_udev_persistent_net ${chroot_dir}
  assertNotEquals $? 0
}

function test_config_udev_persistent_net() {
  config_udev_persistent_net ${chroot_dir}

  [[ -L ${chroot_dir}/etc/udev/rules.d/70-persistent-net.rules ]]
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
