#!/bin/bash
#
# requires:
#  bash
#  dirname, pwd
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## functions

function test_extract_args_commands_success() {
  local opts="a b c d"

  extract_args ${opts}
  assertEquals "${opts}" "${CMD_ARGS}"
}

function test_extract_args_options_success() {
  local commands="command sub-command"
  local options="--key0=value0 --key1=value1"
  local opts="${commands} ${options}"

  extract_args ${opts}
  assertEquals "${commands}" "${CMD_ARGS}"
}

function test_extract_args_underbar_to_hyphen() {
  local commands="command sub-command"
  local options="--k-e-y-0=value0 --k-e-y-1=value1"
  local opts="${commands} ${options}"

  extract_args ${opts}
  assertEquals "${commands}" "${CMD_ARGS}"

  assertEquals "${k_e_y_0}" "value0"
  assertEquals "${k_e_y_1}" "value1"
}

function test_extract_args_commands_simple_opts() {
  local opts="--overwrite --diskless --disk-less"

  extract_args ${opts}

  assertEquals "${overwrite}" "1"
  assertEquals "${diskless}"  "1"
  assertEquals "${disk_less}" "1"
}

## shunit2

. ${shunit2_file}
