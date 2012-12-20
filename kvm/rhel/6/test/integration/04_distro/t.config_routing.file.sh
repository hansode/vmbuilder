#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

declare routetab=${abs_dirname}/../../../examples/routetab.txt.example

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc/sysconfig/network-scripts
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
