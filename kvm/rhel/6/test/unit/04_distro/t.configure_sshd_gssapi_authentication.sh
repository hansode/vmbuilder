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
	GSSAPIAuthentication yes
EOS
  sshd_gssapi_auth=
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_sshd_gssapi_authentication_file_not_found() {
  rm ${chroot_dir}/etc/ssh/sshd_config

  configure_sshd_gssapi_authentication ${chroot_dir} 2>/dev/null
  assertEquals $? 0
}

function test_configure_sshd_gssapi_authentication_empty() {
  configure_sshd_gssapi_authentication ${chroot_dir} >/dev/null

  egrep -q -w "^GSSAPIAuthentication yes" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_gssapi_authentication_yes() {
  local passauth=yes
  configure_sshd_gssapi_authentication ${chroot_dir} ${passauth} >/dev/null

  egrep -q -w "^GSSAPIAuthentication ${passauth}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_gssapi_authentication_no() {
  local passauth=no
  configure_sshd_gssapi_authentication ${chroot_dir} ${passauth} >/dev/null

  egrep -q -w "^GSSAPIAuthentication ${passauth}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_gssapi_authentication_with_sshd_gssapi_auth_yes() {
  local sshd_gssapi_auth=yes
  configure_sshd_gssapi_authentication ${chroot_dir} >/dev/null

  egrep -q -w "^GSSAPIAuthentication ${sshd_gssapi_auth}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_gssapi_authentication_with_sshd_gssapi_auth_no() {
  local sshd_gssapi_auth=no
  configure_sshd_gssapi_authentication ${chroot_dir} >/dev/null

  egrep -q -w "^GSSAPIAuthentication ${sshd_gssapi_auth}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
