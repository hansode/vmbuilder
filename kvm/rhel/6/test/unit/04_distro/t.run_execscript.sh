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

  distro_name=centos
  distro_ver=6
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_run_execscript_executable() {
  run_execscript ${chroot_dir} /bin/echo >/dev/null
  assertEquals $? 0
}

function test_run_execscript_inexecutable() {
  run_execscript ${chroot_dir} /dev/null 2>/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
