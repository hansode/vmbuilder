#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

### arch

function test_add_option_distro_arch_empty() {
  local distro_arch=
  local old_distro_arch=${distro_arch}

  add_option_distro
  assertNotEquals "${old_distro_arch}" "${distro_arch}"
}

function test_add_option_distro_arch_i686() {
  local distro_arch=i686
  local old_distro_arch=${distro_arch}

  add_option_distro
  assertEquals "${old_distro_arch}" "${distro_arch}"
}

function test_add_option_distro_arch_i586() {
  local distro_arch=i586
  local old_distro_arch=${distro_arch}

  add_option_distro
  assertNotEquals "${old_distro_arch}" "${distro_arch}"
}

function test_add_option_distro_arch_i386() {
  local distro_arch=i386
  local old_distro_arch=${distro_arch}

  add_option_distro
  assertNotEquals "${old_distro_arch}" "${distro_arch}"
}

function test_add_option_distro_arch_x86_64() {
  local distro_arch=x86_64
  local old_distro_arch=${distro_arch}

  add_option_distro
  assertEquals "${old_distro_arch}" "${distro_arch}"
}

### distro_name

function test_add_option_distro_name_empty() {
  local distro_name=
  local old_distro_name=${distro_name}

  add_option_distro
  assertNotEquals "${old_distro_name}" "${distro_name}"
}

function test_add_option_distro_name_rhel() {
  local distro_name=rhel
  local old_distro_name=${distro_name}

  add_option_distro
  assertEquals "${old_distro_name}" "${distro_name}"
}

function test_add_option_distro_name_centos() {
  local distro_name=centos
  local old_distro_name=${distro_name}

  add_option_distro
  assertEquals "${old_distro_name}" "${distro_name}"
}

function test_add_option_distro_name_sl() {
  local distro_name=sl
  local old_distro_name=${distro_name}

  add_option_distro
  assertEquals "${old_distro_name}" "${distro_name}"
}

### distro_ver

function test_add_option_distro_ver_empty() {
  local distro_ver=
  local old_distro_ver=${distro_ver}

  add_option_distro
  assertNotEquals "${old_distro_ver}" "${distro_ver}"
}

function test_add_option_distro_ver_major() {
  local distro_ver=6
  local old_distro_ver=${distro_ver}

  add_option_distro
  assertEquals "${old_distro_ver}" "${distro_ver}"
}

function test_add_option_distro_ver_major_minor() {
  local distro_ver=6.0
  local old_distro_ver=${distro_ver}

  add_option_distro
  assertEquals "${old_distro_ver}" "${distro_ver}"
}

### keepcache

function test_add_option_distro_keepcache_empty() {
  local keepcache=
  local old_keepcache=${keepcache}

  add_option_distro
  assertNotEquals "${old_keepcache}" "${keepcache}"
}

function test_add_option_distro_keepcache_0() {
  local keepcache=0
  local old_keepcache=${keepcache}

  add_option_distro
  assertEquals "${old_keepcache}" "${keepcache}"
}

function test_add_option_distro_keepcache_1() {
  local keepcache=1
  local old_keepcache=${keepcache}

  add_option_distro
  assertEquals "${old_keepcache}" "${keepcache}"
}

function test_add_option_distro_keepcache_invalid() {
  local keepcache=2
  local old_keepcache=${keepcache}

  add_option_distro
  # keepcache validation is in configure_keepcache.
  assertEquals "${old_keepcache}" "${keepcache}"
}

### baseurl

function test_add_option_distro_baseurl_empty() {
  local baseurl=
  local old_baseurl=${baseurl}

  add_option_distro
  assertNotEquals "${old_baseurl}" "${baseurl}"
}

function test_add_option_distro_baseurl_exists() {
  local baseurl=http://www.example.com/
  local old_baseurl=${baseurl}

  add_option_distro
  assertEquals "${old_baseurl}" "${baseurl}"
}

### gpgkey

function test_add_option_distro_gpgkey_empty() {
  local gpgkey=
  local old_gpgkey=${gpgkey}

  add_option_distro
  assertNotEquals "${old_gpgkey}" "${gpgkey}"
}

function test_add_option_distro_gpgkey_exists() {
  local gpgkey=asdf
  local old_gpgkey=${gpgkey}

  add_option_distro
  assertEquals "${old_gpgkey}" "${gpgkey}"
}

## shunit2

. ${shunit2_file}
