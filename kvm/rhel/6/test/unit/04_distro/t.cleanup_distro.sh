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
  mkdir -p ${chroot_dir}/var/log
  mkdir -p ${chroot_dir}/tmp
  # should be more than size 0
  date > ${chroot_dir}/var/log/asdf
  date > ${chroot_dir}/tmp/qwer
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_cleanup_distro() {
  cleanup_distro ${chroot_dir}
  assertEquals $? 0
}

function test_cleanup_distro_size_zero() {
  cleanup_distro ${chroot_dir}

  [[ ! -s  ${chroot_dir}/var/log/asdf ]]
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
