#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

declare raw=${disk_filename}
declare distro_name=centos
declare distro_ver=6

## public functions

function setUp() {
  touch ${disk_filename}

  function checkroot() { :; }

  function is_dev() { return 1; }
  function mkdisk() { echo mkdisk $*; }
  function mkptab() { echo mkptab $*; }
  function mapptab() { echo mapptab $*; }
  function mkfsdisk() { echo mkfsdisk $*; }
  function unmapptab() { echo unmapptab $*; }
  function cleanup_distro() { echo cleanup_distro $*; }
  function install_os() { echo install_os $*; }
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_create_vm_disk() {
  create_vm_disk ${disk_filename} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
