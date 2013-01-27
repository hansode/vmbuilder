#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## functions

function test_qemu_kvm() {
  if [[ -f /usr/bin/kvm ]]; then
    which kvm
    assertEquals "$?" "0"
  elif [[ -f /usr/libexec/qemu-kvm ]]; then
    which qemu-kvm
    assertEquals "$?" "0"
  fi
}

## shunit2

. ${shunit2_file}
