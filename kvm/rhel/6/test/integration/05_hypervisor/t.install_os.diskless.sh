#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  add_option_disk
  add_option_distro
  add_option_hypervisor
  [[ -d ${distro_dir} ]] || build_chroot ${distro_dir}
}

function tearDown() { :; }

function test_install_os() {
  (
    set -e
    install_os ${chroot_dir} ${distro_dir}
  )
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
