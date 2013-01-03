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
  function kpartx() { cat <<-EOS
	sda1 : 0 1024000 /dev/sda 2048
	sda2 : 0 485300224 /dev/sda 1026048
	EOS
  }
  function mapped_lodev() { echo mapped_lodev $*; }
  function dmsetup() { echo dmsetup $*; }
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_lsdevmap_dev() {
  function is_dev() { true; }

  assertEquals "$(lsdevmap ${disk_filename})" "sda1
sda2"
}

function test_lsdevmap_file() {
  function is_dev() { false; }

  lsdevmap ${disk_filename}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
