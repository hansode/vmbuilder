# -*-Shell-script-*-
#
# requires:
#   bash
#

## system variables

readonly abs_dirname=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
readonly shunit2_file=${abs_dirname}/../../shunit2

## include files

. ${abs_dirname}/../../../functions/utils.sh
. ${abs_dirname}/../../../functions/mbr.sh
. ${abs_dirname}/../../../functions/disk.sh
. ${abs_dirname}/../../../functions/distro.sh
. ${abs_dirname}/../../../functions/hypervisor.sh
. ${abs_dirname}/../../../functions/vm.sh

## group variables

declare chroot_dir=${abs_dirname}/_chroot.$$
declare disk_filename=${abs_dirname}/_disk.$$.raw

## for create_vm

### variables

declare raw=${disk_filename}

### public functions

function tearDown() {
  rm -rf ${chroot_dir}
  rm -f ${disk_filename}
}
