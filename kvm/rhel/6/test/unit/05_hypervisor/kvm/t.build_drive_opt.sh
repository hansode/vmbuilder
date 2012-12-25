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
  assertEquals "$(${image_path})" ""
}

function test_build_drive_opt_defined_image_path() {
  local image_path="${imagefile_path} ${imagefile_path}.2"

  assertEquals "$(build_drive_opt | wc -l)" 2
}

## shunit2

. ${shunit2_file}
