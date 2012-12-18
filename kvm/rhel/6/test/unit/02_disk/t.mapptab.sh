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
  function kpartx() { cat <<-EOS
	add map loop0p1 (253:3): 0 60484 linear /dev/loop0 63
	add map loop0p2 (253:4): 0 436224 linear /dev/loop0 61440
	add map loop0p3 (253:5): 0 6144 linear /dev/loop0 499712
	add map loop0p4 (253:6): 0 2 linear /dev/loop0 507904
	add map loop0p5 (253:7): 0 747893 linear /dev/loop0 507967
	add map loop0p6 (253:8): 0 122880 linear /dev/loop0 1257472
	add map loop0p7 (253:9): 0 6144 linear /dev/loop0 1382400
	add map loop0p8 (253:10): 0 6144 linear /dev/loop0 1390592
	add map loop0p9 (253:11): 0 6144 linear /dev/loop0 1398784
	EOS
  }
  function udevadm() { :; }
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_mapptab_unmapped() {
  function is_mapped() { false; }

  assertEquals "$(mapptab ${disk_filename})" "$(kpartx ${disk_filename})"
  assertEquals $? 0
}

function test_mapptab_mapped() {
  function is_mapped() { :; }

  mapptab ${disk_filename} >/dev/null
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
