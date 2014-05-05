#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare sshd_config_path=${chroot_dir}/etc/ssh/sshd_config
declare param_name=shunit2.$$
declare default_value=${default_value}

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc/ssh
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_config_sshd_config_file_not_found() {
  rm -f ${sshd_config_path}
  config_sshd_config ${sshd_config_path} ${param_name} no 2>/dev/null
  assertNotEquals $? 0
}

function test_config_sshd_config_enabled() {
  cat <<-EOS > ${sshd_config_path}
	${param_name} ${default_value}
	EOS

  config_sshd_config ${sshd_config_path} ${param_name} no
  assertEquals $? 0
}

function test_config_sshd_config_disabled_comment() {
  cat <<-EOS > ${sshd_config_path}
	#${param_name} ${default_value}
	EOS

  config_sshd_config ${sshd_config_path} ${param_name} no
  assertEquals $? 0
}

function test_config_sshd_config_disabled_comment_whitespace() {
  cat <<-EOS > ${sshd_config_path}
	#  ${param_name} ${default_value}
	EOS

  config_sshd_config ${sshd_config_path} ${param_name} no
  assertEquals $? 0
}

function test_config_sshd_config_with_slash() {
  cat <<-EOS > ${sshd_config_path}
	# AuthorizedKeysFile .ssh/authorized_keys
	EOS

  config_sshd_config ${sshd_config_path} AuthorizedKeysFile .ssh/authorized_keys
  assertEquals $? 0
}

function test_config_sshd_config_disabled_comment_not_exists() {
  cat <<-EOS > ${sshd_config_path}
	EOS

  config_sshd_config ${sshd_config_path} ${param_name} no
  assertEquals $? 0
}


## shunit2

. ${shunit2_file}
