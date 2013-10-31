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
  mkdir -p ${chroot_dir}/etc/vz
  cat <<-EOS > ${chroot_dir}/etc/vz/vz.conf
	IPTABLES="ipt_REJECT ipt_tos ipt_limit ipt_multiport iptable_filter iptable_mangle ipt_TCPMSS ipt_tcpmss ipt_ttl ipt_length"
	EOS
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_vzconf() {
  configure_vzconf ${chroot_dir}
  assertEquals 0 $?

  egrep -q "ipt_recent ipt_owner ipt_REDIRECT ipt_TOS ipt_LOG ip_conntrack ipt_state iptable_nat ip_nat_ftp" ${chroot_dir}/etc/vz/vz.conf
  assertEquals 0 $?
}

## shunit2

. ${shunit2_file}
