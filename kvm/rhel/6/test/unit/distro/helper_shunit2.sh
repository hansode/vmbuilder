# -*-Shell-script-*-
#
# requires:
#   bash
#

## include files

. ../../../functions/disk.sh
. ../../../functions/distro.sh

## variables

shunit2_file=../shunit2

readonly abs_dirname=$(cd $(dirname $0) && pwd)

declare chroot_dir=${abs_dirname}/_chroot.$$
declare disk_filename=${abs_dirname}/_disk.raw.$$

declare rootsize=8
declare swapsize=8
declare optsize=8
declare totalsize=$((${rootsize} + ${swapsize} + ${optsize}))
