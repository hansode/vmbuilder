#!/bin/bash
#
# description:
#  Controll a lxc process
#
# requires:
#  bash
#  dirname, pwd
#  sed, head
#  cat
#  awk, ls, sort
#  ../vmbuilder.sh
#
# import:
#  utils: extract_args, shlog, beautify_process_args
#  hypervisor: gen_macaddr
#              start_lxc, stop_lxc
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
  hypervisor=lxc
}

function controll_lxc() {
  local cmd=$1
  [[ -n "${cmd}" ]] || { echo "[ERROR] Invalid argument: cmd:${cmd} (lxc-ctl.sh:${LINENO})" >&2; return 1; }

  case "${cmd}" in
  build)
    # kind of virt-install
    ${abs_dirname}/../vmbuilder.sh --config-path=${config_path}
    ;;
  start)
    start_lxc ${name}
    ;;
  stop)
    stop_lxc ${name}
    ;;
  info)
    info_lxc ${name}
    ;;
  *)
    echo $"USAGE: $0 [start] OPTIONS..." >&2
    return 2
  ;;
  esac
}

### read-only variables

readonly abs_dirname=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

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
controll_lxc ${cmd}
