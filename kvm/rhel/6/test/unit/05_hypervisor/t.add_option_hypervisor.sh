#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare hypervisor=kvm

## public functions

### distro

function test_add_option_hypervisor_distro_exists() {
  local distro=
  local old_distro=${distro}

  add_option_hypervisor
  assertNotEquals "${old_distro}" "${distro}"
}

function test_add_option_hypervisor_distro_empty() {
  local distro=
  local old_distro=${distro}

  add_option_hypervisor
  assertNotEquals "${old_distro}" "${distro}"
}

### distro_dir

function test_add_option_hypervisor_distro_dir_exists() {
  local distro_dir=
  local old_distro_dir=${distro_dir}

  add_option_hypervisor
  assertNotEquals "${old_distro_dir}" "${distro_dir}"
}

function test_add_option_hypervisor_distro_dir_empty() {
  local distro_dir=
  local old_distro_dir=${distro_dir}

  add_option_hypervisor
  assertNotEquals "${old_distro_dir}" "${distro_dir}"
}

### execscript

function test_add_option_hypervisor_execscript_exists() {
  local execscript=1
  local old_execscript=${execscript}

  add_option_hypervisor
  assertEquals "${old_execscript}" "${execscript}"
}

function test_add_option_hypervisor_execscript_empty() {
  local execscript=
  local old_execscript=${execscript}

  add_option_hypervisor
  assertEquals "${old_execscript}" "${execscript}"
}

### raw

function test_add_option_hypervisor_raw_exists() {
  local raw=1
  local old_raw=${raw}

  add_option_hypervisor
  assertEquals "${old_raw}" "${raw}"
}

function test_add_option_hypervisor_raw_empty() {
  local raw=
  local old_raw=${raw}

  add_option_hypervisor
  assertNotEquals "${old_raw}" "${raw}"
}

### chroot_dir

function test_add_option_hypervisor_chroot_dir_exists() {
  local chroot_dir=1
  local old_chroot_dir=${chroot_dir}

  add_option_hypervisor
  assertEquals "${old_chroot_dir}" "${chroot_dir}"
}

function test_add_option_hypervisor_chroot_dir_empty() {
  local chroot_dir=
  local old_chroot_dir=${chroot_dir}

  add_option_hypervisor
  assertNotEquals "${old_chroot_dir}" "${chroot_dir}"
}

### hypervisor

function test_add_option_hypervisor_hypervisor_kvm() {
  local hypervisor=kvm
  local old_hypervisor=${hypervisor}

  add_option_hypervisor
  assertEquals "${old_hypervisor}" "${hypervisor}"
}

function test_add_option_hypervisor_hypervisor_exists() {
  local hypervisor=
  local old_hypervisor=${hypervisor}

  add_option_hypervisor
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
