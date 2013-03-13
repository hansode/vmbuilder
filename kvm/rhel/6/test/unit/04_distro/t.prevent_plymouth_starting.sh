#!/bin/bash
#
# requires:
#  bash
#  pwd
#  date, egrep
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare chroot_dir=${abs_dirname}/_chroot.$$

## public functions

function render_sysinit() {
  cat <<-'EOS'
	[ "$PROMPT" != no ] && plymouth watch-keystroke --command "touch /var/run/confirm" --keys=Ii &
	[ "$PROMPT" != no ] && plymouth --ignore-keystroke=Ii
	EOS
}

function setUp() {
  mkdir -p ${chroot_dir}/etc/init
  mkdir -p ${chroot_dir}/etc/rc.d

  touch ${chroot_dir}/etc/init/plymouth-shutdown.conf
  touch ${chroot_dir}/etc/init/quit-plymouth.conf
  touch ${chroot_dir}/etc/init/splash-manager.conf

  render_sysinit > ${chroot_dir}/etc/rc.sysinit
  render_sysinit > ${chroot_dir}/etc/rc.d/rc.sysinit

  function chroot() { echo chroot $*; }
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_prevent_plymouth_starting() {
  prevent_plymouth_starting ${chroot_dir}
  assertEquals $? 0
}

function test_prevent_plymouth_starting_file_check() {
  prevent_plymouth_starting ${chroot_dir}

  [[ -f ${chroot_dir}/etc/init/plymouth-shutdown.conf ]]
  assertNotEquals $? 0

  [[ -f ${chroot_dir}/etc/init/quit-plymouth.conf     ]]
  assertNotEquals $? 0

  [[ -f ${chroot_dir}/etc/init/splash-manager.conf    ]]
  assertNotEquals $? 0
}

function test_prevent_plymouth_starting_replacement() {
  prevent_plymouth_starting ${chroot_dir}

  grep -q '[ "$PROMPT" != no ] && [ -n "$PLYMOUTH" ] && plymouth' ${chroot_dir}/etc/rc.sysinit
  assertNotEquals $? 0

  grep -q '[ "$PROMPT" != no ] && [ -n "$PLYMOUTH" ] && plymouth' ${chroot_dir}/etc/rc.d/rc.sysinit
  assertNotEquals $? 0
}

## shunit2

. ${shunit2_file}
