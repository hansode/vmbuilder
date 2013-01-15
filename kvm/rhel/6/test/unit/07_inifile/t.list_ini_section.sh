#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## functions

function test_list_ini_section() {
  assertEquals "$(mycnf | list_ini_section)" "mysqld
mysqld_safe
ifcfg-eth0
ifcfg-eth1"
}

## shunit2

. ${shunit2_file}
