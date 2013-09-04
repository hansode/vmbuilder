#!/bin/bash
#
# requires:
#  bash
#  cd
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare chroot_dir=${abs_dirname}/chroot_dir.$$

## public functions

function setUp() {
  mkdir ${chroot_dir}

  function checkroot() { :; }
  function mkdir() { echo mkdir $*; }
  function mknod() { echo mknod $*; }
  function ln()    { echo ln    $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_after_umount_nonroot() {
  after_umount_nonroot ${chroot_dir} # >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
