#!/bin/bash
#
# requires:
#  bash
#
set -e

### read-only variables

readonly abs_dirname=$(cd $(dirname $0) && pwd)

### include files

. ${abs_dirname}/../functions/utils.sh
. ${abs_dirname}/../functions/disk.sh

### prepare

# disk_filename=$1
convert_disk ${1} $(pwd) vmdk
