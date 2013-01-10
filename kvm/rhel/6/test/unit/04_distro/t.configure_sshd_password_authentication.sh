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
	PasswordAuthentication yes
EOS
  sshd_passauth=
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_sshd_password_authentication_file_not_found() {
  rm ${chroot_dir}/etc/ssh/sshd_config

  configure_sshd_password_authentication ${chroot_dir} 2>/dev/null
  assertEquals $? 0
}

function test_configure_sshd_password_authentication_empty() {
  configure_sshd_password_authentication ${chroot_dir} >/dev/null

  egrep -q -w "^PasswordAuthentication yes" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_password_authentication_yes() {
  local passauth=yes
  configure_sshd_password_authentication ${chroot_dir} ${passauth} >/dev/null

  egrep -q -w "^PasswordAuthentication ${passauth}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_password_authentication_no() {
  local passauth=no
  configure_sshd_password_authentication ${chroot_dir} ${passauth} >/dev/null

  egrep -q -w "^PasswordAuthentication ${passauth}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_password_authentication_with_sshd_passauth_yes() {
  local sshd_passauth=yes
  configure_sshd_password_authentication ${chroot_dir} >/dev/null

  egrep -q -w "^PasswordAuthentication ${sshd_passauth}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_password_authentication_with_sshd_passauth_no() {
  local sshd_passauth=no
  configure_sshd_password_authentication ${chroot_dir} >/dev/null

  egrep -q -w "^PasswordAuthentication ${sshd_passauth}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
