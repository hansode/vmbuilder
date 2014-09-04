#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function test_preflight_check_distro_empty() {
  local baseurl=
  local gpgkey=

  preflight_check_distro >/dev/null 2>&1
  assertNotEquals 0 ${?}
}

function test_preflight_check_distro_baseurl() {
  local baseurl=http://vault.centos.org/6.0/os/x86_64/
  local gpgkey=

  preflight_check_distro >/dev/null 2>&1
  assertNotEquals 0 ${?}
}

function test_preflight_check_distro_baseurl_gpgkey() {
  local baseurl=http://vault.centos.org/6.0/os/x86_64/
  local gpgkey="${gpgkey} ${gpgkey}"

  preflight_check_distro >/dev/null
  assertEquals 0 ${?}
}

## shunit2

. ${shunit2_file}
