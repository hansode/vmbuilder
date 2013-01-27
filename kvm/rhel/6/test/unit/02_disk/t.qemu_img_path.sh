#!/bin/bash
#
# requires:
#  bash
#  cd
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function test_qemu_img_path() {
  [ -f /usr/bin/qemu-img -o -f /usr/bin/kvm-img ] && {
    assertEquals $(qemu_img_path | wc -l) 1
  } || {
    assertEquals $(qemu_img_path | wc -l) 0
  }
}

## shunit2

. ${shunit2_file}
