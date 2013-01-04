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

function test_repofile_cachedir_i386() {
  local distro_arch=i686 distro_ver=6.3
  add_option_distro

  local reponame=${distro_name}

  repofile ${reponame} "${baseurl}" "${gpgkey}" | egrep -q -w ^cachedir=/var/cache/yum/i386/6
  assertEquals $? 0
}

function test_repofile_cachedir_x86_64() {
  local distro_arch=x86_64 distro_ver=6.3
  add_option_distro

  local reponame=${distro_name}

  repofile ${reponame} "${baseurl}" "${gpgkey}" | egrep -q -w ^cachedir=/var/cache/yum/x86_64
  assertEquals $? 0
}


## shunit2

. ${shunit2_file}
