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
  mkdir -p ${chroot_dir}/etc
  cat <<EOS > ${chroot_dir}/etc/yum.conf
[main]
cachedir=/var/cache/yum/$basearch/$releasever
keepcache=0
debuglevel=2
logfile=/var/log/yum.log
exactarch=1
obsoletes=1
gpgcheck=1
plugins=1
installonly_limit=5
bugtracker_url=http://bugs.centos.org/set_project.php?project_id=16&ref=http://bugs.centos.org/bug_report_page.php?category=yum
distroverpkg=centos-release

#  This is the default, if you make this bigger yum won't see if the metadata
# is newer on the remote and so you'll "gain" the bandwidth of not having to
# download the new metadata and "pay" for it by yum not having correct
# information.
#  It is esp. important, to have correct metadata, for distributions like
# Fedora which don't keep old packages around. If you don't like this checking
# interupting your command line usage, it's much better to have something
# manually check the metadata once an hour (yum-updatesd will do this).
# metadata_expire=90m

# PUT YOUR REPOS HERE OR IN separate files named file.repo
# in /etc/yum.repos.d
EOS
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_configure_keepcache_default() {
  local keepcache=

  configure_keepcache ${chroot_dir} | egrep -q -w ^keepcache=1
  assertEquals $? 0
}

function test_configure_keepcache_arg_0() {
  local keepcache=

  configure_keepcache ${chroot_dir} 0 | egrep -q -w ^keepcache=0
  assertEquals $? 0
}

function test_configure_keepcache_arg_1() {
  local keepcache=

  configure_keepcache ${chroot_dir} 1 | egrep -q -w ^keepcache=1
  assertEquals $? 0
}

function test_configure_keepcache_param_0() {
  local keepcache=0

  configure_keepcache ${chroot_dir} | egrep -q -w ^keepcache=${keepcache}
  assertEquals $? 0
}

function test_configure_keepcache_param_1() {
  local keepcache=1

  configure_keepcache ${chroot_dir} | egrep -q -w ^keepcache=${keepcache}
  assertEquals $? 0
}

function test_configure_keepcache_complex() {
  local keepcache=1

  configure_keepcache ${chroot_dir} 0 | egrep -q -w ^keepcache=0
  assertEquals $? 0

  configure_keepcache ${chroot_dir}   | egrep -q -w ^keepcache=${keepcache}
  assertEquals $? 0

  configure_keepcache ${chroot_dir} 1 | egrep -q -w ^keepcache=1
  assertEquals $? 0

  keepcache=0
  configure_keepcache ${chroot_dir}   | egrep -q -w ^keepcache=${keepcache}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
