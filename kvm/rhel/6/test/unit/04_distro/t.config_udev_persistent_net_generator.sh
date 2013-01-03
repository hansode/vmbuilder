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
  mkdir -p ${chroot_dir}/lib/udev/rules.d
  cat <<-EOS > ${chroot_dir}/lib/udev/rules.d/75-persistent-net-generator.rules
	ENV{MATCHADDR}=="00:00:00:00:00:00", ENV{MATCHADDR}=""
EOS
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_config_udev_persistent_net_generator_file_not_found() {
  rm ${chroot_dir}/lib/udev/rules.d/75-persistent-net-generator.rules

  config_udev_persistent_net_generator ${chroot_dir} >/dev/null 2>&1
  assertNotEquals $? 0
}

function test_config_udev_persistent_net_generator() {
  config_udev_persistent_net_generator ${chroot_dir} >/dev/null

  egrep -q '^ENV{MATCHADDR}=="00:00:00:00:00:00", ENV{MATCHADDR}=""' -6 ${chroot_dir}/lib/udev/rules.d/75-persistent-net-generator.rules
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
