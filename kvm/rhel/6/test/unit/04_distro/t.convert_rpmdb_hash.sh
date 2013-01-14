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
  mkdir -p ${chroot_dir}/var/lib/rpm/
  touch    ${chroot_dir}/var/lib/rpm/sample

  function list_rpmdb_file() { echo ${chroot_dir}/var/lib/rpm/sample; }
  function db_dump() { echo db_dump $*; }
  function db43_load() { touch $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_convert_rpmdb_hash_rhel4() {
  distro_name=centos distro_ver=5
  add_option_distro

  convert_rpmdb_hash ${chroot_dir} >/dev/null
  assertEquals $? 0
}

function test_convert_rpmdb_hash_rhel5() {
  distro_name=centos distro_ver=5
  add_option_distro

  convert_rpmdb_hash ${chroot_dir} >/dev/null
  assertEquals $? 0
}

function test_convert_rpmdb_hash_rhel6() {
  distro_name=centos distro_ver=6
  add_option_distro

  convert_rpmdb_hash ${chroot_dir} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
