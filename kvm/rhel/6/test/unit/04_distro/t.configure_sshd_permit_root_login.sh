#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc/ssh
  cat <<-EOS > ${chroot_dir}/etc/ssh/sshd_config
	#PermitRootLogin yes
EOS
  sshd_permit_root_login=
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_sshd_permit_root_login_file_not_found() {
  rm ${chroot_dir}/etc/ssh/sshd_config

  configure_sshd_permit_root_login ${chroot_dir} 2>/dev/null
  assertEquals $? 0
}

function test_configure_sshd_permit_root_login_empty() {
  configure_sshd_permit_root_login ${chroot_dir} >/dev/null

  egrep -q -w "^PermitRootLogin yes" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_permit_root_login_yes() {
  local permit_root_login=yes
  configure_sshd_permit_root_login ${chroot_dir} ${permit_root_login} >/dev/null

  egrep -q -w "^PermitRootLogin ${permit_root_login}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_permit_root_login_no() {
  local permit_root_login=no
  configure_sshd_permit_root_login ${chroot_dir} ${permit_root_login} >/dev/null

  egrep -q -w "^PermitRootLogin ${permit_root_login}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_permit_root_login_without_password() {
  local permit_root_login=without-password
  configure_sshd_permit_root_login ${chroot_dir} ${permit_root_login} >/dev/null

  egrep -q -w "^PermitRootLogin ${permit_root_login}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_permit_root_login_forced_commands_only() {
  local permit_root_login=forced-commands-only
  configure_sshd_permit_root_login ${chroot_dir} ${permit_root_login} >/dev/null

  egrep -q -w "^PermitRootLogin ${permit_root_login}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_permit_root_login_with_sshd_permit_root_login_yes() {
  local sshd_permit_root_login=yes
  configure_sshd_permit_root_login ${chroot_dir} >/dev/null

  egrep -q -w "^PermitRootLogin ${sshd_permit_root_login}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_permit_root_login_with_sshd_permit_root_login_no() {
  local sshd_permit_root_login=no
  configure_sshd_permit_root_login ${chroot_dir} >/dev/null

  egrep -q -w "^PermitRootLogin ${sshd_permit_root_login}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_permit_root_login_with_sshd_permit_root_login_without_password() {
  local sshd_permit_root_login=without-password
  configure_sshd_permit_root_login ${chroot_dir} >/dev/null

  egrep -q -w "^PermitRootLogin ${sshd_permit_root_login}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_permit_root_login_with_sshd_permit_root_login_forced_commands_only() {
  local sshd_permit_root_login=forced-commands-only
  configure_sshd_permit_root_login ${chroot_dir} >/dev/null

  egrep -q -w "^PermitRootLogin ${sshd_permit_root_login}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
