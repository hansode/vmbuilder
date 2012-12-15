#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare raw=${disk_filename}
declare distro_name=centos
declare distro_ver=6

## public functions

function setUp() {
  function is_dev() { return 1; }
  function bootstrap() { echo bootstrap $*; }
  function install_kernel() { echo install_kernel $*; }
  function configure_os() { echo configure_os $*; }
  function cleanup_distro() { echo cleanup_distro $*; }
  function install_os() { echo install_os $*; }
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_create_vm_disk() {
  create_vm_disk ${disk_filename}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
