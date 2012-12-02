#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## functions

declare config_file=config.$$

function setUp() {
  echo 'now="$(date)"' > ${config_file}
}

function tearDown() {
  rm -f ${config_file}
}

function test_load_config_empty() {
  load_config
  assertNotEquals $? 0
}

function test_load_config_exists() {
  load_config ${config_file}
  assertEquals $? 0
}

function test_load_config_access_defined_parameter() {
  load_config ${config_file}
  [[ -n "${now}" ]]
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
