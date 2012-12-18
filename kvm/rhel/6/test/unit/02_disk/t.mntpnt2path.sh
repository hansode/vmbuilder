#!/bin/bash
#
# requires:
#  bash
#  cd, dirname
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  touch ${disk_filename}

  function lsdevmap() { echo lsdevmap $*; }
  function devmap2path() { :; }
  function egrep() { :; }
  function devname2index() { :; }
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_mntpnt2path_root() {
  mntpnt2path ${disk_filename} root
  assertEquals $? 0
}

function test_mntpnt2path_swap() {
  mntpnt2path ${disk_filename} swap
  assertEquals $? 0
}

function test_mntpnt2path_opt() {
  mntpnt2path ${disk_filename} /opt
  assertEquals $? 0
}

function test_mntpnt2path_empty() {
  mntpnt2path ${disk_filename} 2>/dev/null
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
