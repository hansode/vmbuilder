#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare routetab=${abs_dirname}/../../../examples/routetab.txt.example

## public functions

function setUp() {
  mkdir -p ${chroot_dir}

  function install_routing() { echo install_routing $*; }
}

function tearDown() {
  rm -f ${routetab_file}
  rm -rf ${chroot_dir}
}

function test_config_routing() {
  config_routing ${chroot_dir}
}

## shunit2

. ${shunit2_file}
