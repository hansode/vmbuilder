#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

declare distro_name=centos
declare distro_ver=6

## public functions

### required options

function test_repofile_required_opts_empty() {
  local reponame= baseurl= gpgkey=

  repofile ${reponame} "${baseurl}" "${gpgkey}" 2>/dev/null | egrep -q ^baseurl=${baseurl}
  assertNotEquals $? 0
}

function test_repofile_required_reponame() {
  add_option_distro
  local reponame=${distro_name}
  local baseurl= gpgkey=

  repofile ${reponame} "${baseurl}" "${gpgkey}" 2>/dev/null | egrep -q ^baseurl=${baseurl}
  assertNotEquals $? 0
}

function test_repofile_required_reponame_baseurl() {
  add_option_distro
  local reponame=${distro_name}
  local gpgkey=

  repofile ${reponame} "${baseurl}" "${gpgkey}" 2>/dev/null | egrep -q ^baseurl=${baseurl}
  assertNotEquals $? 0
}

function test_repofile_required_reponame_baseurl_gpgkey() {
  add_option_distro
  local reponame=${distro_name}

  repofile ${reponame} "${baseurl}" "${gpgkey}" | egrep -q ^baseurl=${baseurl}
  assertEquals $? 0
}

### optional options

function test_repofile_optonal_keepcache_empty() {
  add_option_distro
  local reponame=${distro_name}
  local keepcache=

  repofile ${reponame} "${baseurl}" "${gpgkey}" | egrep -q ^keepcache=1
  assertEquals $? 0
}

function test_repofile_optonal_keepcache_exists() {
  add_option_distro
  local reponame=${distro_name}
  local keepcache=1

  repofile ${reponame} "${baseurl}" "${gpgkey}" | egrep -q ^keepcache=${keepcache}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
