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

  function checkroot() { :; }
  function kpartx() { :; }
  function dmsetup() { :; }
  function losetup() { :; }
  function mapped_lodev() { :; }
  function lsdevmap() { cat <<-EOS
	loop0p1
	loop0p2
	EOS
  }
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_unmapptab() {
  unmapptab ${disk_filename} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
