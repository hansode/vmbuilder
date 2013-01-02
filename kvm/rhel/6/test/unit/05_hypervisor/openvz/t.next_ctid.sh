#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

declare chroot_dir=${abs_dirname}/chroot_dir.$$
declare vz_conf_dir=${chroot_dir}/etc/vz/conf

## public functions

function setUp() {
  mkdir -p ${vz_conf_dir}
  touch ${vz_conf_dir}/0.conf
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_next_ctid() {
  assertEquals "$(next_ctid ${vz_conf_dir})" 101
}

function test_next_ctid_dir_101() {
  local curid=101
  touch ${vz_conf_dir}/${curid}.conf

  assertEquals "$(next_ctid ${vz_conf_dir})" "$((${curid} + 1))"
}

function test_next_ctid_dir_234() {
  local curid=234
  touch ${vz_conf_dir}/${curid}.conf

  assertEquals "$(next_ctid ${vz_conf_dir})" "$((${curid} + 1))"
}

## shunit2

. ${shunit2_file}
