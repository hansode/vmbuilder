#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

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

  config_host_and_domainname ${chroot_dir} | egrep -q -w ^HOSTNAME=${hostname}
  assertEquals $? 0
}

function test_config_host_and_domainname_with_host_localhost() {
  local hostname=localhost

  config_host_and_domainname ${chroot_dir} >/dev/null
  assertEquals 1 $(egrep ${hostname} ${chroot_dir}/etc/hosts | wc -l)
}

function test_config_host_and_domainname_with_host_non_localhost() {
  local hostname=non_localhost

  config_host_and_domainname ${chroot_dir} >/dev/null
  assertEquals 1 $(egrep ${hostname} ${chroot_dir}/etc/hosts | wc -l)
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
