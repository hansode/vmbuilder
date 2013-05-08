#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function test_build_kvm_opts() {
  build_kvm_opts >/dev/null
  assertEquals $? 0
}

function test_build_kvm_opts_name() {
  local name=vmbulder

  build_kvm_opts | egrep -q -w -- "-name ${name}"
  assertEquals $? 0
}

## pidfile

function test_build_kvm_opts_no_pidfile() {
  local pidfile=

  build_kvm_opts | egrep -q -w -- "-pidfile ${pidfile}"
  assertEquals $? 0
}

function test_build_kvm_opts_with_pidfile() {
  local pidfile=${abs_dirname}/kvm.pid

  build_kvm_opts | egrep -q -w -- "-pidfile ${pidfile}"
  assertEquals $? 0
}

## rtc

function test_build_kvm_opts_no_rtc() {
  local rtc=

  build_kvm_opts | egrep -q -w -- "-rtc ${rtc}"
  assertEquals $? 0
}

function test_build_kvm_opts_with_rtc() {
  local rtc="base=host"

  build_kvm_opts | egrep -q -w -- "-rtc ${rtc}"
  assertEquals $? 0
}

## cpu_type

function test_build_kvm_opts_no_cpu_type() {
  local cpu_type=

  build_kvm_opts | egrep -q -w -- "-cpu ${cpu_type}"
  assertEquals $? 0
}

function test_build_kvm_opts_with_cpu_type() {
  local cpu_type="qemu64,+vmx "

  # don't use *e*grep
  build_kvm_opts | grep -q -w -- "-cpu ${cpu_type}"
  assertEquals $? 0
}


## shunit2

. ${shunit2_file}
