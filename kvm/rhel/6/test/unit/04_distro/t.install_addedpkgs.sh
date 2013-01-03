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

  function run_yum() { echo run_yum $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_install_addedpkgs_empty() {
  assertEquals "$(install_addedpkgs ${chroot_dir})" ""
}

function test_install_addedpkgs_defined() {
  local addpkg="make gcc g++"

  install_addedpkgs ${chroot_dir} | grep -q "${addpkg}"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
