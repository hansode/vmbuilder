#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare raw=${disk_filename}
declare distro_name=centos
declare distro_ver=6

declare hypervisor=lxc

## public functions

function setUp() {
  function install_os() { echo install_os $*; }
}

function tearDown() {
  :
}

function test_create_vm_tree() {
  declare distro_dir=${abs_dirname}/distro_dir.$$

  create_vm_tree ${chroot_dir} ${distro_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
