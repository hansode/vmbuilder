#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_preflight_check_uri_empty() {
  preflight_check_uri
  assertNotEquals $? 0
}

function test_preflight_check_uri_http() {
  preflight_check_uri http://ftp.riken.go.jp/pub/Linux/centos/6/os/x86_64/
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
