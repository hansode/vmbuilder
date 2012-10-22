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
  mkfsdisk ${disk_filename}

  function sync_os() { echo sync_os $*; }
  function mount_proc() { echo mount_proc $*; }
  function mount_dev() { echo mount_dev $*; }
  function configure_networking() { echo configure_networking $*; }
  function configure_mounting() { echo configure_mounting $*; }
  function configure_keepcache() { echo configure_keepcache $*; }
 #function configure_selinux() { echo configure_selinux $*; }
  function erase_selinux() { echo erase_selinux $*; }
  function prevent_daemons_starting() { echo prevent_daemons_starting $*; }
  function create_initial_user() { echo create_initial_user $*; }
  function set_timezone() { echo set_timezone $*; }
  function install_kernel() { echo install_kernel $*; }
  function install_bootloader() { echo install_bootloader $*; }
  function run_execscript() { echo run_execscript $*; }
}

function tearDown() {
  unmapptab ${disk_filename}
  rm -f ${disk_filename}
  rm -rf ${distro_dir}
}

function test_install_os_distro_short_empty() {
  local distro_short=
  install_os ${chroot_dir} ${distro_dir} ${disk_filename}
  assertNotEquals $? 0
}

function test_install_os_distro_short_empty() {
  local distro_short=centos
  install_os ${chroot_dir} ${distro_dir} ${disk_filename}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
