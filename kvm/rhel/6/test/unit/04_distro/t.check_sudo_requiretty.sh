#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare sudoers_path=${abs_dirname}/sudoers.$$

## public functions

function setUp() {
  touch ${sudoers_path}
}

function tearDown() {
  [[ -f ${sudoers_path} ]] && rm -f ${sudoers_path}
}

function test_check_sudo_requiretty_file_not_found() {
  rm -f ${sudoers_path}

  check_sudo_requiretty ${sudoers_path} 2>/dev/null
  assertNotEquals $? 0
}

function test_check_sudo_requiretty_enabled() {
  cat <<-EOS > ${sudoers_path}
	Defaults    requiretty
	EOS

  check_sudo_requiretty ${sudoers_path}
  assertEquals $? 0
}

function test_check_sudo_requiretty_disabled() {
  cat <<-EOS > ${sudoers_path}
	# Defaults    requiretty
	EOS

  check_sudo_requiretty ${sudoers_path}
  assertNotEquals $? 0
}


## shunit2

. ${shunit2_file}
