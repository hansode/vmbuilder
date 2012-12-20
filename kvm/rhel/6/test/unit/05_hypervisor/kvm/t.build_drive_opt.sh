#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## variables

declare imagefile_path=${abs_dirname}/image_path.$$

## public functions

function test_build_drive_opt_no_opts() {
  build_drive_opt | egrep file=,
  assertEquals $? 0
}

function test_build_drive_opt_defined_image_path() {
  local image_path=${imagefile_path}

  build_drive_opt | egrep file=${image_path},
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
