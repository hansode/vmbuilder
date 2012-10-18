#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc/sysconfig
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_config_host_and_domainname() {
  config_host_and_domainname ${chroot_dir}
  assertEquals $? 0
}

function test_config_host_and_domainname_with_dns() {
  local dns=8.8.8.8
  config_host_and_domainname ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
