# -*-Shell-script-*-
#
# description:
#  Master Boot Recorder
#
# requires:
#  bash
#  dd
#
# imports:
#

## mbr(master boot record)

function rmmbr() {
  local if_path=$1
  [[ -a "${if_path}" ]] || { echo "[ERROR] file not found: ${if_path} (mbr:${LINENO})" >&2; return 1; }

  dd if=/dev/zero of=${if_path} bs=512 count=1
}
