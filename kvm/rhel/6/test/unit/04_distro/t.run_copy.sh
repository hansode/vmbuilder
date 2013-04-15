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
	${abs_dirname}/sbin/baz /sbin/baz mode=0755 owner=owner group=group
	EOS
  function install() { echo install $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
  rm -f  ${abs_dirname}/src
  rm -f  ${abs_dirname}/foo
  rm -f  ${copyfile}
}

function test_run_copy_found() {
  run_copy ${chroot_dir} ${copyfile} >/dev/null
  assertEquals $? 0
}

function test_run_copy_not_found() {
  run_copy ${chroot_dir} ${abs_dirname}/_$$.copy 2>/dev/null
  assertNotEquals $? 0
}

function test_run_copy_file_attributes_no_opts() {
  run_copy ${chroot_dir} ${copyfile} | egrep -q "install --mode 0644 --owner root --group root"
  assertEquals $? 0
}

function test_run_copy_file_attributes_mode_owner_group() {
  run_copy ${chroot_dir} ${copyfile} | egrep /sbin/baz | egrep -q "install --mode 0755 --owner owner --group group"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
