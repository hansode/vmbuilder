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
#  egrep, xargs, cut
#  awk, ls, sort
#  ../vmbuilder.sh
#
# import:
#  utils: extract_args, shlog
#  hypervisor: qemu_kvm_path, gen_macaddr, build_vif_opt
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
}

function kvmof() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (kvm-ctl:${LINENO})" >&2; return 1; }

  list_kvm | egrep -w -- "-name ${name}"
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
    checkroot || return 1

    while read arg; do
      case "${arg}" in
      -*) echo -n "${arg}"  ;;
       *) echo    " ${arg}" ;;
      esac
    done < <(kvmof ${name} | xargs echo | cut -d' ' -f9- | sed "s, ,\n,g")
    echo

    local pid=$(kvmof ${name} | awk '{print $2}')
    [[ -z "${pid}" ]] || {
      echo
      # 1. list kvm process fd
      # 2. delete "total XXX"
      # 3. order by fd number
      ls -l /proc/${pid}/fd/ | sed -e 1d |  sort -k 9 -n
    }
    ;;
  list)
    list_kvm
    ;;
  dump)
    cat <<-EOS
	name=${name}
	image_format=${image_format}
	image_file=${image_file}
	image_path=${image_path}

	brname=${brname}

	kvm_path=${kvm_path}
	kvm_opts=${kvm_opts}

	mem_size=${mem_size}
	cpu_num=${cpu_num}

	vnc_addr=${vnc_addr}
	vnc_port=${vnc_port}

	monitor_addr=${monitor_addr}
	monitor_port=${monitor_port}

	serial_addr=${serial_addr}
	serial_port=${serial_port}
	EOS
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
. ${abs_dirname}/../functions/hypervisor/kvm.sh

### prepare

extract_args $*

### main

cmd="$(echo ${CMD_ARGS} | sed "s, ,\n,g" | head -1)"

[[ -f "${config_path}" ]] && load_config ${config_path} || :
register_options
add_option_hypervisor_kvm
run_kvm ${cmd}
