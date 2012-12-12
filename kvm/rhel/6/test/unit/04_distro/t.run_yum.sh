#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables


## public functions

function setUp() {
  mkdir -p ${chroot_dir}
  function run_yum() { echo run_yum $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_run_yum_distro_name_empty() {
  run_yum ${chroot_dir} help
  assertEquals $? 0
}

function test_run_yum_distro_name_exists_help() {
  add_option_distro
  local distro_name=centos distro_ver=6

  run_yum ${chroot_dir} help
  assertEquals $? 0
}

function test_run_yum_distro_name_exists_repolist() {
  add_option_distro
  local distro_name=centos distro_ver=6

  run_yum ${chroot_dir} repolist
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
