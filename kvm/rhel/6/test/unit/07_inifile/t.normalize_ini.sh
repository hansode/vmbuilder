#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## functions

function setUp() {
  mycnf > ${inifile}
}

function tearDown() {
  rm -f ${inifile}
}

function test_normalize_ini_filter() {
  mycnf | normalize_ini >/dev/null
  assertEquals $? 0
}

function test_normalize_ini_file() {
  normalize_ini ${inifile} >/dev/null
  assertEquals $? 0
}

function test_normalize_ini_redirect() {
  normalize_ini < ${inifile} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
