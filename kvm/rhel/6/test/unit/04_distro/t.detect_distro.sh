#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

declare distrib_flavor=RedHat
declare distrib_id=CentOS
declare distrib_release=6.3

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/etc
  cat <<-EOS > ${chroot_dir}/etc/redhat-release
	${distrib_id} release ${distrib_release} (Final)
	EOS
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_routetabinfo() {
 #detect_distro ${chroot_dir}

  detect_distro ${chroot_dir} | egrep ^DISTRIB_FLAVOR=${distrib_flavor}
  assertEquals $? 0

  detect_distro ${chroot_dir} | egrep ^DISTRIB_ID=${distrib_id}
  assertEquals $? 0

  detect_distro ${chroot_dir} | egrep ^DISTRIB_RELEASE=${distrib_release}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
