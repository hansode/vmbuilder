#!/bin/bash
#
# description:
#  Controll a kvm process
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
#  hypervisor: qemu_kvm_path, gen_macaddr, build_vif_opt, kvmof
#              kvm_start, kvm_stop, kvm_console, kvm_info, kvm_list, kvm_dump
#
# usage:
#
#  $0 start --image-path=/path/to/vmimage.raw
#  $0 start --image-path=/path/to/vmimage.raw --kvm-opts="-enable-nesting"
#
set -e

## private functions

function register_options() {
  debug=${debug:-}
  [[ -z "${debug}" ]] || set -x

  config_path=${config_path:-}
  name=${name:-rhel6}
  hypervisor=kvm
}

function controll_kvm() {
  local cmd=$1
  [[ -n "${cmd}" ]] || { echo "[ERROR] Invalid argument: cmd:${cmd} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  case "${cmd}" in
  build)
    # kind of virt-install
    ${abs_dirname}/../vmbuilder.sh --config-path=${config_path}
    ;;
  start)
    kvm_start ${name}
    ;;
  stop)
    kvm_stop ${monitor_addr} ${monitor_port}
    ;;
  console)
    kvm_console ${serial_addr} ${serial_port}
    ;;
  info)
    kvm_info ${name}
    ;;
  list)
    kvm_list
    ;;
  render-runscript)
    render_kvm_runscript ${name}
    ;;
  dump)
    kvm_dump
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
controll_kvm ${cmd}
