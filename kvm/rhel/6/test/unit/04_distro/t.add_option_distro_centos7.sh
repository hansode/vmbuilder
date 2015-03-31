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
  distro_name=centos
  distro_ver=7
  baseurl=
}

### arch

function test_add_option_distro_centos7() {
  add_option_distro

  assertEquals "${distro_ver}" "${distro_ver_latest}"
}

function test_add_option_distro_centos7_baseurl_old() {
  distro_ver=7.0.1406
  add_option_distro
  [[ "${baseurl}" =~ "vault" ]]
  assertEquals 0 ${?}
}

function test_add_option_distro_centos7_baseurl_latest() {
  add_option_distro
  [[ "${baseurl}" =~ "vault" ]]
  assertNotEquals 0 ${?}
}

## shunit2

. ${shunit2_file}
