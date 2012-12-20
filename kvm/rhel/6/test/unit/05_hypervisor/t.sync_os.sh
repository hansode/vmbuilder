#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

declare distro_dir=${abs_dirname}/_distro.$$

## public functions

function tree_dir() {
  local target_dir=$1
  find ${target_dir} -type f | sed "s,^${target_dir},,"
}

function setUp() {
  mkdir -p ${chroot_dir}
  mkdir -p ${distro_dir}
  touch ${distro_dir}/dummy
}

function tearDown() {
  rm -rf ${chroot_dir}
  rm -rf ${distro_dir}
}

function test_sync_os() {
  # ${distro_dir} -> ${chroot_dir}
  sync_os ${distro_dir} ${chroot_dir}
  assertEquals $? 0

  # compare file
  assertEquals "$(tree_dir ${chroot_dir})" "$(tree_dir ${distro_dir})"
}

## shunit2

. ${shunit2_file}
