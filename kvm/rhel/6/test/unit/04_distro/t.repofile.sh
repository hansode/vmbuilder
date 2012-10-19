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
  add_option_distro
}

function test_repofile() {
  local reponame=${distro_name}

  repofile ${reponame} "${baseurl}" "${gpgkey}" ${keepcache} | egrep -q ^baseurl=${baseurl}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
