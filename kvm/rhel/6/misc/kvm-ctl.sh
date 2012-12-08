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
#              start_kvm, stop_kvm, console_kvm, info_kvm, list_kvm, dump_kvm
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

function run_kvm() {
  case "$1" in
  build)
    # kind of virt-install
    ${abs_dirname}/../vmbuilder.sh --config-path=${config_path}
    ;;
  start)
    start_kvm ${name}
    ;;
  stop)
    stop_kvm ${monitor_addr} ${monitor_port}
    ;;
  console)
    console_kvm ${serial_addr} ${serial_port}
    ;;
  info)
    info_kvm ${name}
    ;;
  list)
    list_kvm
    ;;
  dump)
    dump_kvm
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

cmd="$(echo ${CMD_ARGS} | sed "s, ,\n,g" | head -1)"

[[ -f "${config_path}" ]] && load_config ${config_path} || :
register_options
add_option_hypervisor
run_kvm ${cmd}
