# -*-Shell-script-*-
#
# requires:
#   bash
#

## system variables

readonly abs_dirname=$(cd $(dirname $0) && pwd)
readonly shunit2_file=${abs_dirname}/../../shunit2

## include files

. ${abs_dirname}/../../../functions/utils.sh
. ${abs_dirname}/../../../functions/disk.sh
. ${abs_dirname}/../../../functions/mbr.sh
. ${abs_dirname}/../../../functions/distro.sh

## group variables

declare chroot_dir=${abs_dirname}/_chroot.$$
