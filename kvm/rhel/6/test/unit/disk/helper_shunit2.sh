# -*-Shell-script-*-
#
# requires:
#   bash
#

## include files

. ../../../functions/disk.sh

## variables

shunit2_file=../shunit2

readonly abs_dirname=$(cd $(dirname $0) && pwd)

declare chroot_dir=${abs_dirname}/_chroot.$$
declare disk_filename=${abs_dirname}/_disk.raw.$$
