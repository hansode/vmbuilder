#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

### required options

function test_repofile_required_opts_empty() {
  local reponame= baseurl= gpgkey= keepcache=

  repofile ${reponame} "${baseurl}" "${gpgkey}" ${keepcache} | egrep -q ^baseurl=${baseurl}
  assertNotEquals $? 0
}

function test_repofile_required_reponame() {
  add_option_distro
  local reponame=${distro_short}
  local baseurl= gpgkey=

  repofile ${reponame} "${baseurl}" "${gpgkey}" ${keepcache} | egrep -q ^baseurl=${baseurl}
  assertNotEquals $? 0
}

function test_repofile_required_reponame_baseurl() {
  add_option_distro
  local reponame=${distro_short}
  local gpgkey=

  repofile ${reponame} "${baseurl}" "${gpgkey}" ${keepcache} | egrep -q ^baseurl=${baseurl}
  assertNotEquals $? 0
}

function test_repofile_required_reponame_baseurl_gpgkey() {
  add_option_distro
  local reponame=${distro_short}

  repofile ${reponame} "${baseurl}" "${gpgkey}" ${keepcache} | egrep -q ^baseurl=${baseurl}
  assertEquals $? 0
}

### optional options

function test_repofile_optonal_keepcache_empty() {
  add_option_distro
  local reponame=${distro_short}
  local keepcache=

  repofile ${reponame} "${baseurl}" "${gpgkey}" ${keepcache} | egrep -q ^baseurl=${baseurl}
  assertEquals $? 0
}

function test_repofile_optonal_keepcache_exists() {
  add_option_distro
  local reponame=${distro_short}
  local keepcache=1

  repofile ${reponame} "${baseurl}" "${gpgkey}" ${keepcache} | egrep -q ^baseurl=${baseurl}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
