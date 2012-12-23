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

function setUp() {
  mkdir -p ${distro_dir}

  mkdisk ${disk_filename} $(sum_disksize)
  mkptab ${disk_filename}
  mapptab ${disk_filename}
  mkfsdisk ${disk_filename} ext4

  function sync_os() { echo sync_os $*; }
  function mount_proc() { echo mount_proc $*; }
  function mount_dev() { echo mount_dev $*; }
  function mount_sys() { echo mount_sys $*; }
  function create_initial_user() { echo create_initial_user $*; }
  function install_authorized_keys() { echo install_authorized_keys $*; }
  function configure_networking() { echo configure_networking $*; }
  function configure_mounting() { echo configure_mounting $*; }
  function configure_keepcache() { echo configure_keepcache $*; }
  function configure_console() { echo configure_console $*; }
  function configure_hypervisor() { echo configure_hypervisor $*; }
  function configure_selinux() { echo configure_selinux $*; }
  function configure_sshd_password_authentication() { echo configure_sshd_password_authentication $*; }
  function install_kernel() { echo install_kernel $*; }
  function install_bootloader() { echo install_bootloader $*; }
  function install_epel() { echo install_epel $*; }
  function install_addedpkgs() { echo install_addedpkgs $*; }
  function run_copy()       { echo run_copy       $*; }
  function run_execscript() { echo run_execscript $*; }
  function install_firstboot() { echo install_firstboot $*; }
  function install_firstlogin() { echo install_firstlogin $*; }
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
