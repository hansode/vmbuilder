#!/bin/bash
#
# description:
#  Controll a openvz process
#
# requires:
#  bash
#  pwd
#  sed, head
#  cat
#  awk, ls, sort
#  ../vmbuilder.sh
#
# import:
#  utils: extract_args, shlog
#  hypervisor: gen_macaddr
#              openvz_create, openvz_start, openvz_stop, openvz_destroy, openvz_console, openvz_status
#
# usage:
#
#  $0 start --image-path=/path/to/vmimage.raw
#
set -e

## private functions

function register_options() {
  debug=${debug:-}
  [[ -z "${debug}" ]] || set -x

  config_path=${config_path:-}
  name=${name:-rhel6}
  hypervisor=openvz
}

function controll_openvz() {
  local cmd=$1
  [[ -n "${cmd}" ]] || { echo "[ERROR] Invalid argument: cmd:${cmd} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  case "${cmd}" in
  build)
    # kind of virt-install
    ${abs_dirname}/../vmbuilder.sh --config-path=${config_path} --hypervisor=${hypervisor} --diskless
    ;;
  create|start|stop|destroy|console|status)
    openvz_${cmd} ${name}
    ;;
  list)
    openvz_${cmd}
    ;;
  *)
    echo "[ERROR] no such command: ${cmd} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
    return 2
  ;;
  esac
}

### read-only variables

readonly abs_dirname=$(cd ${BASH_SOURCE[0]%/*} && pwd)

### include files

. ${abs_dirname}/../functions/utils.sh
. ${abs_dirname}/../functions/hypervisor.sh

### prepare

extract_args $*

### main

declare cmd="$(echo ${CMD_ARGS} | sed "s, ,\n,g" | head -1)"

[[ -f "${config_path}" ]] && load_config ${config_path} || :
register_options
add_option_hypervisor
controll_openvz ${cmd}
