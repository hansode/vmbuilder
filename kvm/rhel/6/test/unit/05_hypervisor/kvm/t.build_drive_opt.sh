#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

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

function test_build_drive_opt_defined_image_path_and_cdrom() {
  local image_path="${imagefile_path} ${imagefile_path}.2"
  local cdrom_path=${abs_dirname}/cdrom_path.$$

  assertEquals "$(build_drive_opt | wc -l)" 3
}

function test_build_drive_opt_defined_drive_type_empty() {
  local image_path="${imagefile_path}"

  local drive_type=
  build_drive_opt | egrep -q -v ,if=virtio
  assertEquals $? 0
}

function test_build_drive_opt_defined_drive_type_scsi() {
  local image_path="${imagefile_path}"

  local drive_type=scsi
  build_drive_opt | egrep -q ,if=scsi
  assertEquals $? 0
}

function test_build_drive_opt_defined_drive_type_virtio() {
  local image_path="${imagefile_path}"

  local drive_type=virtio
  build_drive_opt | egrep -q ,if=virtio
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
