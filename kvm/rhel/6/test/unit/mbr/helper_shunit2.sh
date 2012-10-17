# -*-Shell-script-*-
#
# requires:
#   bash
#

## include files

. ../../../functions/mbr.sh

## variables

shunit2_file=../shunit2

readonly abs_dirname=$(cd $(dirname $0) && pwd)

declare disk_filename=${abs_dirname}/_disk.raw.$$
