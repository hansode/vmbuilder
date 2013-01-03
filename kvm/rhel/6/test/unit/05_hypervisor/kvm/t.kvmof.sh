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
  add_option_hypervisor_kvm
  function ps() { echo "root      4659     1  3 14:51 ?        00:00:12 /usr/libexec/qemu-kvm -name rhel6 -m 1024 -smp 1 -vnc 0.0.0.0:1001 -k en-us -drive file=./centos-6.3_x86_64.raw,media=disk,boot=on,index=0,cache=none -monitor telnet:127.0.0.1:4444,server,nowait -serial telnet:127.0.0.1:5555,server,nowait -netdev tap,ifname=rhel6-4444,id=hostnet0,script=,downscript= -device virtio-net-pci,netdev=hostnet0,mac=52:54:00:14:51:46,bus=pci.0,addr=0x3 -daemonize" ; }
}

function test_kvmof_known_name() {
  assertEquals $(kvmof rhel6 | wc -l) 1
}

function test_kvmof_unknown_name() {
  assertEquals $(kvmof rhel | wc -l) 0
}

## shunit2

. ${shunit2_file}
