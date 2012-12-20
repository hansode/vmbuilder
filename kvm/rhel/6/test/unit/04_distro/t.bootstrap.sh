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
  distro_name=centos
  distro_ver=6

  add_option_distro

  function checkroot() { :; }
  function mkdevice() { :; }
  function mkprocdir() { :; }
  function mount_proc() { :; }
  function run_yum() { :; }
  function umount_nonroot() { :; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_bootstrap() {
  bootstrap ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
