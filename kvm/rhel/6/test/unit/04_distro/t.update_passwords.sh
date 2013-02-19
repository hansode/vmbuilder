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
  mkdir -p ${chroot_dir}

  function chroot() { echo chroot $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_update_passwords_empty_rootpass() {
  local rootpass=

  update_passwords ${chroot_dir} | egrep -q -w "^chroot ${chroot_dir} bash -e -c usermod -L root"
  assertEquals $? 0
}

function test_update_passwords_rootpass() {
  local rootpass=asdf

  update_passwords ${chroot_dir} | egrep -q -w "^chroot ${chroot_dir} bash -e -c echo root:${rootpass} | chpasswd"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
