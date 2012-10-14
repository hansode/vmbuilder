# -*-Shell-script-*-
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## functions

test_extract_args_commands_success() {
  local opts="a b c d"
  extract_args ${opts}
  assertEquals "${opts}" "${CMD_ARGS}"
}

test_extract_args_options_success() {
  local commands="command sub-command"
  local options="--key0=value0 --key1=value1"
  local opts="${commands} ${options}"
  extract_args ${opts}
  assertEquals "${commands}" "${CMD_ARGS}"
}

## shunit2

. ${shunit2_file}
