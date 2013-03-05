#!/bin/bash
#
# requires:
#  bash
#  pwd
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## functions

function test_basearch() {
  basearch >/dev/null
  assertEquals "$?" "0"
}

function test_basearch_i386() {
  local arch=
  for arch in i386 i486 i586 i686; do
    assertEquals "$(basearch ${arch})" i386
  done
}

function test_basearch_x86_64() {
  local arch=
  for arch in x86_64; do
    assertEquals "$(basearch ${arch})" x86_64
  done
}

function test_basearch_unknown() {
  local arch=
  for arch in i286 i786 asdf unknown; do
    basearch ${arch} >/dev/null
    assertNotEquals $? 0
  done
}

## shunit2

. ${shunit2_file}
