#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare copyfile=${abs_dirname}/copy.$$

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/tmp
  echo src > ${abs_dirname}/src
  echo foo > ${abs_dirname}/foo
  cat <<-EOS > ${copyfile}
	${abs_dirname}/src /tmp/dst
	
	${abs_dirname}/foo /tmp/var
	${abs_dirname}/zzz /tmp/zzz
	EOS
  function install() { echo install $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
  rm -f  ${abs_dirname}/src
  rm -f  ${abs_dirname}/foo
  rm -f  ${copyfile}
}

function test_run_copies_file() {
  run_copies ${chroot_dir} ${copyfile} >/dev/null
  assertEquals $? 0
}

function test_run_copies_files() {
  run_copies ${chroot_dir} ${copyfile} ${copyfile} >/dev/null
  assertEquals $? 0
}

function test_run_copies_no_opts() {
  run_copies ${chroot_dir} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
