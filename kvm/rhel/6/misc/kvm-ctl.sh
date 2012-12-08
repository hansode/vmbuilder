#!/bin/bash
#
# description:
#  Controll a kvm process
#
# requires:
#  bash
#  dirname, pwd
#  sed, head
#  date, seq, cat, ip, brctl
#  telnet, ps, egrep, xargs, cut
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

  image_format=${image_format:-raw}
  image_file=${image_file:-${name}.${image_format}}
  image_path=${image_path:-${image_file}}

  brname=${brname:-br0}

  kvm_path=${kvm_path:-$(qemu_kvm_path)}
  kvm_opts=${kvm_opts:-}

  mem_size=${mem_size:-1024}
  cpu_num=${cpu_num:-1}

  vnc_addr=${vnc_addr:-0.0.0.0}
  vnc_port=${vnc_port:-1001}
  vnc_keymap=${vnc_keymap:-en-us} # [ en-us | ja ]

  monitor_addr=${monitor_addr:-127.0.0.1}
  monitor_port=${monitor_port:-4444}

  serial_addr=${serial_addr:-127.0.0.1}
  serial_port=${serial_port:-5555}

  vif_num=${vif_num:-1}
  viftab=${viftab:-}

  vendor_id=${vendor_id:-52:54:00}
}

function kvmof() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (kvm-ctl:${LINENO})" >&2; return 1; }

  $0 list | egrep -w -- "-name ${name}"
}

function run_kvm() {
  case "$1" in
  build)
    # kind of virt-install
    ${abs_dirname}/../vmbuilder.sh --config-path=${config_path}
    ;;
  start)
    checkroot || return 1

    shlog ${kvm_path} ${kvm_opts} \
     -name     ${name} \
     -m        ${mem_size} \
     -smp      ${cpu_num} \
     -vnc      ${vnc_addr}:${vnc_port} \
     -k        ${vnc_keymap} \
     -drive    file=${image_path},media=disk,boot=on,index=0,cache=none \
     -monitor  telnet:${monitor_addr}:${monitor_port},server,nowait \
     -serial   telnet:${serial_addr}:${serial_port},server,nowait \
     $(build_vif_opt ${vif_num}) \
     -daemonize

    viftabproc <<'EOS'
      shlog ip link set ${vif_name} up
      [[ -z "${bridge_if}" ]] || shlog brctl addif ${bridge_if} ${vif_name}
EOS
    ;;
  stop)
    exec 5<>/dev/tcp/${monitor_addr}/${monitor_port}
    echo quit >&5
    cat  <&5 >/dev/null
    exec <&5-
    ;;
  console)
    telnet ${serial_addr} ${serial_port}
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
    ps -ef | egrep -w ${kvm_path} | egrep -v "egrep -w ${kvm_path}"
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

### prepare

extract_args $*

### main

cmd="$(echo ${CMD_ARGS} | sed "s, ,\n,g" | head -1)"

[[ -f "${config_path}" ]] && load_config ${config_path} || :
register_options
run_kvm ${cmd}
