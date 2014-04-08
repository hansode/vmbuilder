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

function setUp() {
  touch ${disk_filename}

  function checkroot() { :; }
  function kpartx() { :; }
  function dmsetup() { :; }
  function losetup() { echo losetup ${@}; }
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
  assertEquals 0 ${?}
}

function test_unmapptab_mapped() {
  function mapped_lodev() { echo loop0; }

  unmapptab ${disk_filename} >/dev/null
  assertEquals 0 ${?}
}

## shunit2

. ${shunit2_file}
