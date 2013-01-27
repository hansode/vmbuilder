#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function test_qemu_kvm_path() {
  [ -f /usr/bin/qemu-img -o -f /usr/bin/kvm-img ] && {
    qemu_kvm_path >/dev/null
  } || {
    :
  }
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
