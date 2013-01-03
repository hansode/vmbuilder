#!/bin/bash
#
# description:
#  Map/Unmap raw file
#
# requires:
#  bash
#  pwd
#  sed, head
#
# import:
#  utils: extract_args
#  disk: mapptab, unmapptab, is_mapped, lsdevmap
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
}

function raw_mapper() {
  local cmd=$1
  [[ -n "${cmd}" ]] || { echo "[ERROR] Invalid argument: cmd:${cmd} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  checkroot || return 1

  case "${cmd}" in
  map|unmap)
    ${cmd}ptab ${image_path}
    ;;
  ls)
    is_mapped ${image_path} && {
      lsdevmap ${image_path}
    } || {
      echo "[WARN] file not mapped: ${image_path} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2
      return 2
    }
    ;;
  *)
    echo "[ERROR] no such command: ${cmd} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2
    return 1
    ;;
  esac
}

### read-only variables

readonly abs_dirname=$(cd ${BASH_SOURCE[0]%/*} && pwd)

### include files

. ${abs_dirname}/../functions/utils.sh
. ${abs_dirname}/../functions/disk.sh

### prepare

extract_args $*

### main

declare cmd="$(echo ${CMD_ARGS} | sed "s, ,\n,g" | head -1)"

[[ -f "${config_path}" ]] && load_config ${config_path} || :
register_options
raw_mapper ${cmd}
