#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc

  function cause_daemons_starting() { echo cause_daemons_starting $*; }
  function chroot() { echo chroot $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_acpid_installation() {
  configure_acpid ${chroot_dir} | egrep -q -w "yum install -y acpid"
  assertEquals $? 0
}

function test_configure_acpid_service_starting() {
  configure_acpid ${chroot_dir} | egrep -q -w "cause_daemons_starting ${chroot_dir} acpid"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
