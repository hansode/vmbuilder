#!/bin/bash
#
# description:
#  Mount/Umount a ptab (mapped raw file)
#
# requires:
#  bash
#  pwd
#  sed, head
#  egrep
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
  mntpnt_path=${mntpnt_path:-${PWD}/mnt}
}

function ptab_mounter() {
  local cmd=$1
  [[ -n "${cmd}" ]] || { echo "[ERROR] Invalid argument: cmd:${cmd} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  case "${cmd}" in
  mount|umount)
    [[ -d "${mntpnt_path}" ]] || { echo "[ERROR] no such directory: ${mntpnt_path} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

    case "${cmd}" in
    mount)  ${cmd}_ptab ${image_path} ${mntpnt_path} ;;
    umount) ${cmd}_ptab               ${mntpnt_path} ;;
    esac

    ;;
  ls)
    mount | egrep ${mntpnt_path}
    ;;
  *)
    echo "[ERROR] no such command: ${cmd} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
    return 1
    ;;
  esac
}

### read-only variables

readonly abs_dirname=$(cd ${BASH_SOURCE[0]%/*} && pwd)

### include files

. ${abs_dirname}/../functions/utils.sh
. ${abs_dirname}/../functions/disk.sh
. ${abs_dirname}/../functions/hypervisor.sh

### prepare

extract_args $*

### main

declare cmd="$(echo ${CMD_ARGS} | sed "s, ,\n,g" | head -1)"

[[ -f "${config_path}" ]] && load_config ${config_path} || :
register_options
add_option_disk
ptab_mounter ${cmd}
