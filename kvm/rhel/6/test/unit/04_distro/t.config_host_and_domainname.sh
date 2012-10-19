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

### set value

function test_config_host_and_domainname() {
  config_host_and_domainname ${chroot_dir}
  assertEquals $? 0
}

function test_config_host_and_domainname_with_host() {
  local hostname=github.com

  config_host_and_domainname ${chroot_dir}
  assertEquals $? 0
}

function test_config_host_and_domainname_with_domainname() {
  local dns=8.8.8.8

  config_host_and_domainname ${chroot_dir}
  assertEquals $? 0
}

### set empty

function test_config_host_and_domainname_with_host_empty() {
  local hostname=

  config_host_and_domainname ${chroot_dir}
  assertEquals $? 0
}

function test_config_host_and_domainname_with_domainname_empty() {
  local dns=

  config_host_and_domainname ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
