#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare inifile_path=${abs_dirname}/mycnf.$$

## functions

function setUp() {
  mycnf > ${inifile_path}
}

function tearDown() {
  rm -f ${inifile_path}
}

function test_list_ini_section_pipe() {
  assertEquals "$(mycnf | list_ini_section)" "mysqld
mysqld_safe
ifcfg-eth0
ifcfg-eth1"
}

function test_list_ini_section_namedpipe() {
  assertEquals "$(list_ini_section <(mycnf))" "mysqld
mysqld_safe
ifcfg-eth0
ifcfg-eth1"
}

function test_list_ini_section_file() {
  assertEquals "$(list_ini_section ${inifile_path})" "mysqld
mysqld_safe
ifcfg-eth0
ifcfg-eth1"
}

function test_list_ini_section_redirect() {
  assertEquals "$(list_ini_section < ${inifile_path})" "mysqld
mysqld_safe
ifcfg-eth0
ifcfg-eth1"
}

## shunit2

. ${shunit2_file}
