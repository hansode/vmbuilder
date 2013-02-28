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

  function run_in_target() { echo run_in_target $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_install_epel_empty() {
  install_epel ${chroot_dir}
  assertEquals $? 0
}

function test_install_epel_defined() {
  local epel_uri=http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/6/i386/epel-release-6-8.noarch.rpm

  install_epel ${chroot_dir} | egrep -q -w "rpm -Uvh ${epel_uri}"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
