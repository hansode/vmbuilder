#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare copyfile=${abs_dirname}/copy.$$
declare srcdummy_644=${abs_dirname}/dummy_644.$$
declare srcdummy_755=${abs_dirname}/dummy_755.$$

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/tmp
  echo src > ${abs_dirname}/src
  echo foo > ${abs_dirname}/foo
  echo 644 > ${srcdummy_644}; chmod 644 ${srcdummy_644}
  echo 755 > ${srcdummy_755}; chmod 755 ${srcdummy_755}

  cat <<-EOS > ${copyfile}
	${abs_dirname}/src /tmp/dst
	
	${abs_dirname}/foo /tmp/var
	${abs_dirname}/sbin/baz /sbin/baz mode=0755 owner=owner group=group

	${srcdummy_644} /tmp/dummy_644
	${srcdummy_755} /tmp/dummy_755
	# SRC  DST
	# SRC1 DST2
	EOS
  function install() { echo install $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
  rm -f  ${abs_dirname}/src
  rm -f  ${abs_dirname}/foo
  rm -f  ${copyfile}
  rm -f  ${srcdummy_644}
  rm -f  ${srcdummy_755}
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
  run_copy ${chroot_dir} ${copyfile} | egrep -q "install -p --mode 644 --owner root --group root"
  assertEquals $? 0
}

function test_run_copy_file_attributes_mode_owner_group() {
  run_copy ${chroot_dir} ${copyfile} | egrep /sbin/baz | egrep -q "install -p --mode 0755 --owner owner --group group"
  assertEquals $? 0
}

function test_run_copy_file_to_keep_attribute() {
  run_copy ${chroot_dir} ${copyfile} | egrep -q "install -p --mode 644 --owner root --group root ${srcdummy_644}"
  assertEquals $? 0

  run_copy ${chroot_dir} ${copyfile} | egrep -q "install -p --mode 755 --owner root --group root ${srcdummy_755}"
  assertEquals $? 0
}

function test_run_copy_file_comments() {
  run_copy ${chroot_dir} ${copyfile} | egrep -q '^#'
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
