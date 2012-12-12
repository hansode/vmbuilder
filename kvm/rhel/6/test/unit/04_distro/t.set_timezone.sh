#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare distro_name=centos
declare distro_ver=6

## public functions

function setUp() {
  mkdir -p ${chroot_dir}
  mkdir -p ${chroot_dir}/usr/share/zoneinfo
  mkdir -p ${chroot_dir}/etc
  touch ${chroot_dir}/usr/share/zoneinfo/Japan
  add_option_distro
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_set_timezone() {
  set_timezone ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
