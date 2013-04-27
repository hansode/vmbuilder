#!/bin/bash
#
# requires:
#  bash
#
# imports:
#  utils:
#  disk: convert_disk
#
set -e

### read-only variables

readonly abs_dirname=$(cd ${BASH_SOURCE[0]%/*} && pwd)

### include files

. ${abs_dirname}/../functions/utils.sh
. ${abs_dirname}/../functions/disk.sh

### prepare

declare disk_filename=${1}

[[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; exit 1; }
convert_disk ${disk_filename} $(pwd) qcow2
