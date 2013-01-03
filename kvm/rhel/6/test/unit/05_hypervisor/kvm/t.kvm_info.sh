#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare ps_output="root      4659     1  3 14:51 ?        00:00:12 /usr/libexec/qemu-kvm -name rhel6 -m 1024 -smp 1 -vnc 0.0.0.0:1001 -k en-us -drive file=./centos-6.3_x86_64.raw,media=disk,boot=on,index=0,cache=none -monitor telnet:127.0.0.1:4444,server,nowait -serial telnet:127.0.0.1:5555,server,nowait -netdev tap,ifname=rhel6-4444,id=hostnet0,script=,downscript= -device virtio-net-pci,netdev=hostnet0,mac=52:54:00:14:51:46,bus=pci.0,addr=0x3 -daemonize"
declare ls_output="total 0
lrwx------ 1 root root 64 Dec  8 14:51 0 -> /dev/null
lrwx------ 1 root root 64 Dec  8 14:51 1 -> /dev/null
lrwx------ 1 root root 64 Dec  8 14:51 10 -> /home/scientific/work/repos/git/github.com/vmbuilder/kvm/rhel/6/centos-6.3_x86_64.raw
lrwx------ 1 root root 64 Dec  8 14:51 11 -> anon_inode:[signalfd]
lrwx------ 1 root root 64 Dec  8 14:51 12 -> socket:[16626]
lrwx------ 1 root root 64 Dec  8 14:51 13 -> anon_inode:kvm-vcpu
lrwx------ 1 root root 64 Dec  8 14:51 14 -> socket:[16628]
lrwx------ 1 root root 64 Dec  8 14:51 15 -> anon_inode:[eventfd]
lrwx------ 1 root root 64 Dec  8 14:51 16 -> anon_inode:[eventfd]
lrwx------ 1 root root 64 Dec  8 14:51 17 -> anon_inode:[signalfd]
lrwx------ 1 root root 64 Dec  8 14:51 2 -> /dev/null
lrwx------ 1 root root 64 Dec  8 14:51 3 -> socket:[16599]
lrwx------ 1 root root 64 Dec  8 14:51 4 -> /dev/kvm
l-wx------ 1 root root 64 Dec  8 14:51 5 -> pipe:[16600]
lrwx------ 1 root root 64 Dec  8 14:51 6 -> anon_inode:kvm-vm
lr-x------ 1 root root 64 Dec  8 14:51 7 -> pipe:[16602]
l-wx------ 1 root root 64 Dec  8 14:51 8 -> pipe:[16602]
lrwx------ 1 root root 64 Dec  8 14:51 9 -> /dev/net/tun"

## public functions

function setUp() {
  add_option_hypervisor_kvm

  function checkroot() { :; }
  function ps() { echo "${ps_output}"; }
  function ls() { echo "${ls_output}"; }
}

function test_kvm_info_no_opts() {
  kvm_info >/dev/null 2>&1
  assertNotEquals $? 0
}

function test_kvm_info_known() {
  kvm_info rhel6 | egrep -q -w "${ls_output}"
}

## shunit2

. ${shunit2_file}
