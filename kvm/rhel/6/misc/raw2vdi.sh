#!/bin/bash
#
# requires:
#  bash
#
set -e

### read-only variables

readonly abs_dirname=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

### include files

. ${abs_dirname}/../functions/utils.sh
. ${abs_dirname}/../functions/disk.sh

### prepare

declare disk_filename=${1}

[[ -f "${disk_filename}" ]] || { echo "no such file: ${disk_filename}" >&2; exit 1; }
convert_disk ${disk_filename} $(pwd) vdi
