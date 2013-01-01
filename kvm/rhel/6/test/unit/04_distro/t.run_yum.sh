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
  mkdir -p ${chroot_dir}
  function yum() { echo yum $*; }

  distro_name=centos
  distro_ver=6
  add_option_distro
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_run_yum_distro_name_exists_help() {
  run_yum ${chroot_dir} help | egrep -q -w 'help$'
  assertEquals $? 0
}

function test_run_yum_distro_name_exists_repolist() {
  run_yum ${chroot_dir} repolist | egrep -q -w 'repolist$'
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
