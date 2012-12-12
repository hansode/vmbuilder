#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare distro_dir=${abs_dirname}/_distro_dir
declare distro_name=centos
declare distro_ver=6

## public functions

function setUp() {
  add_option_disk
  add_option_distro
  add_option_hypervisor
  [[ -d ${distro_dir} ]] || build_chroot ${distro_dir}

  mkdisk   ${disk_filename} ${totalsize}
  mkptab   ${disk_filename}
  mapptab  ${disk_filename}
  mkfsdisk ${disk_filename} ext4
}

function tearDown() {
  umount_ptab ${chroot_dir}
  unmapptab   ${disk_filename}
  rm -f       ${disk_filename}
}

function test_install_os() {
  (
    set -e
    install_os ${chroot_dir} ${distro_dir} ${disk_filename}
  )
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
