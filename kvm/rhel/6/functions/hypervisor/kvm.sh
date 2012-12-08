# -*-Shell-script-*-
#
# description:
#  Hypervisor kvm
#
# requires:
#  bash
#  /usr/libexec/qemu-kvm, /usr/bin/kvm
#
# imports:
#  hypervisor: viftabproc
#

function add_option_hypervisor_kvm() {
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

function qemu_kvm_path() {
  local execs="/usr/libexec/qemu-kvm /usr/bin/kvm"

  local command_path=
  for exe in ${execs}; do
    [[ -x "${exe}" ]] && command_path=${exe} || :
  done

  [[ -n "${command_path}" ]] || { echo "[ERROR] command not found: ${execs} (hypervisor:${LINENO})." >&2; return 1; }
  echo ${command_path}
}

function build_vif_opt() {
  local vif_name macaddr bridge_if

  viftabproc <<-'EOS'
    local offset=$((${index} - 1))
    local netdev_id=hostnet${offset}
    # "addr" should be more than 0x3
    local addr="0x$((3 + ${offset}))"

    case "${macaddr}" in
    "-") macaddr=$(gen_macaddr ${offset}) ;;
    esac

    echo \
      -netdev tap,ifname=${vif_name},id=${netdev_id},script=,downscript= \
      -device virtio-net-pci,netdev=${netdev_id},mac=${macaddr},bus=pci.0,addr=${addr}
EOS
}
