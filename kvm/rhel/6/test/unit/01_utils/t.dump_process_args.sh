#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare chroot_dir=${abs_dirname}/_chroot.$$

## public functions

test_dump_process_args() {
  local process="root pid 1 0 00:01 ? 00:00:00 /path/to/command -name asdf -m 128 -smp 1"

  assertEquals \
   "$(echo ${process} | dump_process_args)" \
   "-name
asdf
-m
128
-smp
1"
}

## shunit2

. ${shunit2_file}
