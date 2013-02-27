#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare xexecscript_path=${abs_dirname}/xexecscript.$$.ssh

## public functions

function setUp() {
  mkdir -p ${chroot_dir}

  distro_name=centos
  distro_ver=6

  cat <<-EOS > ${xexecscript_path}
	#!/bin/bash
	echo $*
	EOS
  chmod +x ${xexecscript_path}
}

function tearDown() {
  rm -f  ${xexecscript_path}
  rm -rf ${chroot_dir}
}

function test_run_xexecscript_executable() {
  run_xexecscript ${chroot_dir} ${xexecscript_path} >/dev/null
  assertEquals $? 0
}

function test_run_xexecscript_inexecutable() {
  run_xexecscript ${chroot_dir} /dev/null 2>/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
