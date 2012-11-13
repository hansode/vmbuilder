#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

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


## shunit2

. ${shunit2_file}
