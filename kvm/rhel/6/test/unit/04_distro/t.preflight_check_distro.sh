#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_preflight_check_distro_empty() {
  local baseurl=
  preflight_check_distro
  assertNotEquals $? 0
}

function test_preflight_check_distro_http() {
  local baseurl=http://ftp.riken.go.jp/pub/Linux/centos/6/os/x86_64/
  preflight_check_distro
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
