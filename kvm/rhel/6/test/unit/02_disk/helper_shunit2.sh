# -*-Shell-script-*-
#
# requires:
#  bash
#  cd
#

## system variables

readonly abs_dirname=$(cd ${BASH_SOURCE[0]%/*} && pwd)
readonly shunit2_file=${abs_dirname}/../../shunit2

## include files

. ${abs_dirname}/../../../functions/utils.sh
. ${abs_dirname}/../../../functions/disk.sh

## group variables

declare chroot_dir=${abs_dirname}/_chroot.$$
declare disk_filename=${abs_dirname}/_disk.$$.raw

declare rootsize=8
declare swapsize=8
declare optsize=8
