#!/bin/bash
#
# description:
#  Controll a dnsmasq process
#
# requires:
#  bash
#  pwd
#  sed, head
#  cat
#  dnsmasq, ps, rm
#
# import:
#  utils: extract_args
#
# usage:
#
#  $0 [ start | stop | status ]
#
set -e

## private functions

function register_options() {
  debug=${debug:-}
  [[ -z "${debug}" ]] || set -x

  config_path=${config_path:-}
  pid_file=${pid_file:-/var/tmp/dnsmasq.pid}
  listen_address=${listen_address:-10.0.2.2}
  dhcp_range=${dhcp_range:-10.0.2.20,10.0.2.99}
  dhcp_lease_max=${dhcp_lease_max:-79}
  dhcp_leasefile=${dhcp_leasefile:-/var/tmp/dnsmasq.leases}
}

function controll_dnsmasq() {
  local cmd=$1
  [[ -n "${cmd}" ]] || { echo "[ERROR] Invalid argument: cmd:${cmd} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  case "${cmd}" in
  start)
    [[ -f "${pid_file}" ]] && { echo "[ERROR] pid file exists: ${pid_file} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

    /usr/sbin/dnsmasq \
     --strict-order \
     --bind-interfaces \
     --pid-file=${pid_file} \
     --conf-file= \
     --except-interface lo \
     --listen-address ${listen_address} \
     --dhcp-range     ${dhcp_range}     \
     --dhcp-lease-max=${dhcp_lease_max} \
     --dhcp-leasefile=${dhcp_leasefile} \
     --dhcp-no-override
    ;;
  stop)
    [[ -f "${pid_file}" ]] || { echo "[ERROR] file not found: ${pid_file} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
    local pid=$(cat ${pid_file})
    [[ -n "${pid}" ]] || { echo "[ERROR] pid not found: ${pid} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

    kill  ${pid}
    rm -f ${pid_file}
    ;;
  status)
    [[ -f "${pid_file}" ]] || { echo "[ERROR] file not found: ${pid_file} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
    local pid=$(cat ${pid_file})
    [[ -n "${pid}" ]] || { echo "[ERROR] pid not found: ${pid} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
    [[ -f "${dhcp_leasefile}" ]] || { echo "[WARN] file not found: ${dhcp_leasefile} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 0; }

    ps -ef | awk "\$2 == ${pid}"
    cat ${dhcp_leasefile}
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

### prepare

extract_args $*

### main

declare cmd="$(echo ${CMD_ARGS} | sed "s, ,\n,g" | head -1)"

[[ -f "${config_path}" ]] && load_config ${config_path} || :
register_options
controll_dnsmasq ${cmd}
