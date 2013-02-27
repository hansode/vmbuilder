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

function test_run_execscripts_file() {
  run_execscripts ${chroot_dir} /bin/echo >/dev/null
  assertEquals $? 0
}

function test_run_execscripts_files() {
  run_execscripts ${chroot_dir} /bin/echo /bin/true >/dev/null
  assertEquals $? 0
}

function test_run_execscripts_no_opts() {
  run_execscripts ${chroot_dir} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
