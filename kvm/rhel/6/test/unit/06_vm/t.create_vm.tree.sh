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
  function preflight_check_distro() { echo preflight_check_distro $*; }
  function is_dev() { return 1; }
  function bootstrap() { echo bootstrap $*; }
  function install_kernel() { echo install_kernel $*; }
  function configure_os() { echo configure_os $*; }
  function cleanup_distro() { echo cleanup_distro $*; }
  function install_os() { echo install_os $*; }
  function create_vm_disk() { echo create_vm_disk $*; }
  function create_vm_tree() { echo create_vm_tree $*; }
}

function tearDown() {
  rm -f ${disk_filename}
}

function test_create_vm() {
  local disk_filename= raw= hypervisor=

  # *** always create_vm_disk is called so far ***
  create_vm
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
