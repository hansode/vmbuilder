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
. ${abs_dirname}/../functions/mbr.sh
. ${abs_dirname}/../functions/distro.sh
. ${abs_dirname}/../functions/hypervisor.sh
. ${abs_dirname}/../functions/vm.sh

### prepare

extract_args $*
function install_os() { :; }

## main

create_vm_disk ${raw:-sandbox.raw}
