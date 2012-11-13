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
declare totalsize=$((${rootsize} + ${swapsize} + ${optsize}))
