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
  mkdir -p ${chroot_dir}/proc
  mkdir -p ${chroot_dir}/dev
  mkdir -p ${chroot_dir}/sys

  function checkroot() { :; }
  function mount() { echo mount $*; }
  function prevent_daemons_starting() { echo prevent_daemons_starting $*; }
  function configure_keepcache() { echo configure_keepcache $*; }
  function install_extras() { echo install_extras $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_os() {
  configure_os ${chroot_dir} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
