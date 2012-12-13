#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function setUp() {
  add_option_hypervisor_lxc

  function checkroot() { echo checkroot $*; }
  function shlog() { echo shlog $*; }
}

function test_start_lxc() {
  start_lxc vmbuilder
}

## shunit2

. ${shunit2_file}
