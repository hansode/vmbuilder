#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function test_preflight_check_uri_empty() {
  preflight_check_uri >/dev/null 2>&1
  assertNotEquals $? 0
}

function test_preflight_check_uri_http() {
  preflight_check_uri http://vault.centos.org/6.0/os/x86_64/ >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
