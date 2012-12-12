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
. ${abs_dirname}/../../../functions/disk.sh
. ${abs_dirname}/../../../functions/distro.sh
. ${abs_dirname}/../../../functions/hypervisor.sh

## group variables

declare chroot_dir=${abs_dirname}/_chroot.$$
declare disk_filename=${abs_dirname}/_disk.$$.raw

declare rootsize=800
declare swapsize=0
declare optsize=0

declare hypervisor=kvm

declare distro_dir=${abs_dirname}/_distro_dir
declare distro_name=centos
declare distro_ver=6

## public functions

function additional_setUp() {
  :
  # interface
}

function additional_tearDown() {
  :
  # interface
}

function setUp() {
  add_option_disk
  add_option_distro
  add_option_hypervisor
  [[ -d ${distro_dir} ]] || build_chroot ${distro_dir}

  mkdisk   ${disk_filename} $(sum_disksize)
  mkptab   ${disk_filename}
  mapptab  ${disk_filename}
  mkfsdisk ${disk_filename} ext4

  additional_setUp
}

function tearDown() {
  umount_ptab ${chroot_dir}
  unmapptab   ${disk_filename}
  rm -f       ${disk_filename}

  additional_tearDown
}
