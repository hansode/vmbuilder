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
