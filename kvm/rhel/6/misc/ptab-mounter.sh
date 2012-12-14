#!/bin/bash
#
# description:
#  Mount/Umount a ptab (mapped raw file)
#
# requires:
#  bash
#  dirname, pwd
#  sed, head
#
# import:
#  utils: extract_args
#  disk: add_option_disk
#  hypervisor: mount_ptab, umount_ptab
#
# usage:
#
#  $0 COMMAND --config-path=/path/to/config
#
set -e

## private functions

function register_options() {
  debug=${debug:-}
  [[ -z "${debug}" ]] || set -x

  config_path=${config_path:-}
  image_path=${image_path:-${image_file}}
  mntpnt_path=${mntpnt_path:-`pwd`/mnt}
}

function ptab_mounter() {
  checkroot || return 1

  case "$1" in
  mount|umount)
    [[ -d "${mntpnt_path}" ]] || {
      echo "[ERROR] directory not found: ${mntpnt_path}." >&2
      return 1
    }

    case "${1}" in
    mount)  ${1}_ptab ${image_path} ${mntpnt_path} ;;
    umount) ${1}_ptab               ${mntpnt_path} ;;
    esac

    ;;
  *)
    echo "[ERROR] no such command: ${1}" >&2
    return 1
    ;;
  esac
}

### read-only variables

readonly abs_dirname=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

### include files

. ${abs_dirname}/../functions/utils.sh
. ${abs_dirname}/../functions/disk.sh
. ${abs_dirname}/../functions/hypervisor.sh

### prepare

extract_args $*

### main

cmd="$(echo ${CMD_ARGS} | sed "s, ,\n,g" | head -1)"

[[ -f "${config_path}" ]] && load_config ${config_path} || :
register_options
add_option_disk
ptab_mounter ${cmd}
