#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdisk ${disk_filename} $(sum_disksize)
  mkdir -p ${chroot_dir}/etc

  function render_fstab() { cat <<-EOS
	tmpfs                   /dev/shm                tmpfs   defaults        0 0
	devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
	sysfs                   /sys                    sysfs   defaults        0 0
	proc                    /proc                   proc    defaults        0 0
	EOS
  }
}

function tearDown() {
  rm ${disk_filename}
  rm -rf ${chroot_dir}
}

function test_install_fstab() {
  install_fstab ${chroot_dir} ${disk_filename}
  assertEquals $? 0
}


## shunit2

. ${shunit2_file}
