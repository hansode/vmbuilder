# -*-Shell-script-*-
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## functions

test_checkroot_failed() {
  checkroot
  assertNotEquals "${?}" "0"
}

## shunit2

. ${shunit2_file}
