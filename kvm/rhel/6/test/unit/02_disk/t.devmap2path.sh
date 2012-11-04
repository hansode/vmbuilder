#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function test_devmap2path_loop() {
  local devname=loop0

  assertEquals $(echo ${devname} | devmap2path) /dev/mapper/${devname}
}

function test_devmap2path_nonloop() {
  local devname=sdb

  assertEquals $(echo ${devname} | devmap2path) /dev/${devname}
}

## shunit2

. ${shunit2_file}
