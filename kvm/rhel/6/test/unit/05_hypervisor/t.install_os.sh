#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare distro_dir=${abs_dirname}/_distro.$$

## public functions

function setUp() {
  mkdir -p ${distro_dir}

  mkdisk ${disk_filename} ${totalsize}
  mkptab ${disk_filename}
  mapptab ${disk_filename}
  mkfsdisk ${disk_filename} ext4

  function sync_os() { echo sync_os $*; }
  function mount_proc() { echo mount_proc $*; }
  function mount_dev() { echo mount_dev $*; }
  function mount_sys() { echo mount_sys $*; }
  function configure_networking() { echo configure_networking $*; }
  function configure_mounting() { echo configure_mounting $*; }
  function configure_keepcache() { echo configure_keepcache $*; }
  function install_kernel() { echo install_kernel $*; }
  function install_bootloader() { echo install_bootloader $*; }
  function run_copy()       { echo run_copy       $*; }
  function run_execscript() { echo run_execscript $*; }
}

function tearDown() {
  unmapptab ${disk_filename}
  rm -f ${disk_filename}
  rm -rf ${distro_dir}
}

function test_install_os_distro_name_empty() {
  local distro_name=
  install_os ${chroot_dir} ${distro_dir} ${disk_filename}
  assertNotEquals $? 0
}

function test_install_os_distro_name_empty() {
  local distro_name=centos
  install_os ${chroot_dir} ${distro_dir} ${disk_filename}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
