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
	#UseDNS yes
EOS
  sshd_use_dns=
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_sshd_use_dns_file_not_found() {
  rm ${chroot_dir}/etc/ssh/sshd_config

  configure_sshd_use_dns ${chroot_dir} 2>/dev/null
  assertEquals $? 0
}

function test_configure_sshd_use_dns_empty() {
  configure_sshd_use_dns ${chroot_dir} >/dev/null

  egrep -q -w "^UseDNS yes" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_use_dns_yes() {
  local use_dns=yes
  configure_sshd_use_dns ${chroot_dir} ${use_dns} >/dev/null

  egrep -q -w "^UseDNS ${use_dns}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_use_dns_no() {
  local use_dns=no
  configure_sshd_use_dns ${chroot_dir} ${use_dns} >/dev/null

  egrep -q -w "^UseDNS ${use_dns}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_use_dns_with_sshd_use_dns_yes() {
  local sshd_use_dns=yes
  configure_sshd_use_dns ${chroot_dir} >/dev/null

  egrep -q -w "^UseDNS ${sshd_use_dns}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

function test_configure_sshd_use_dns_with_sshd_use_dns_no() {
  local sshd_use_dns=no
  configure_sshd_use_dns ${chroot_dir} >/dev/null

  egrep -q -w "^UseDNS ${sshd_use_dns}" ${chroot_dir}/etc/ssh/sshd_config
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
