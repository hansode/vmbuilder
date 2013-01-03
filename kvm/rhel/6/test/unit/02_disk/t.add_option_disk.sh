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
  disk_name=centos
  disk_ver=6
}

##

### chroot_dir

function test_add_option_disk_chroot_dir_exists() {
  local chroot_dir=1
  local old_chroot_dir=${chroot_dir}

  add_option_disk
  assertEquals "${old_chroot_dir}" "${chroot_dir}"
}

function test_add_option_disk_chroot_dir_empty() {
  local chroot_dir=
  local old_chroot_dir=${chroot_dir}

  add_option_disk
  assertNotEquals "${old_chroot_dir}" "${chroot_dir}"
}

### distro

function test_add_option_disk_distro_exists() {
  local distro=
  local old_distro=${distro}

  add_option_disk
  assertNotEquals "${old_distro}" "${distro}"
}

function test_add_option_disk_distro_empty() {
  local distro=
  local old_distro=${distro}

  add_option_disk
  assertNotEquals "${old_distro}" "${distro}"
}

### distro_dir

function test_add_option_disk_distro_dir_exists() {
  local distro_dir=
  local old_distro_dir=${distro_dir}

  add_option_disk
  assertNotEquals "${old_distro_dir}" "${distro_dir}"
}

function test_add_option_disk_distro_dir_empty() {
  local distro_dir=
  local old_distro_dir=${distro_dir}

  add_option_disk
  assertNotEquals "${old_distro_dir}" "${distro_dir}"
}

### raw

function test_add_option_disk_raw_exists() {
  local raw=1
  local old_raw=${raw}

  add_option_disk
  assertEquals "${old_raw}" "${raw}"
}

function test_add_option_disk_raw_empty() {
  local raw=
  local old_raw=${raw}

  add_option_disk
  assertNotEquals "${old_raw}" "${raw}"
}


## shunit2

. ${shunit2_file}
