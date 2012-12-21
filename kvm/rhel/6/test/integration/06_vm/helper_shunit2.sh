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
declare distro_name=centos
declare distro_ver=6
declare hypervisor=kvm

## for create_vm

### variables

declare raw=${disk_filename}

### public functions

function additional_tearDown() {
  :
  # abstract
}

function tearDown() {
  umount_ptab ${chroot_dir}
  unmapptab   ${disk_filename}

  rm -rf ${chroot_dir}
  rm -f  ${disk_filename}

  additional_tearDown
}
