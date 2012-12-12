#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_install_os_distro_install_epel() {
  local epel_uri=http://ftp.riken.jp/Linux/fedora/epel/6/i386/epel-release-6-7.noarch.rpm
  (
    set -e
    install_os ${chroot_dir} ${distro_dir} ${disk_filename}
  )
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
