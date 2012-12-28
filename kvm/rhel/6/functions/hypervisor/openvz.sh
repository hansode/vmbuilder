# -*-Shell-script-*-
#
# description:
#  Hypervisor openvz
#
# requires:
#  bash, basename
#
# imports:
#  utils: shlog
#  hypervisor: configure_container
#

function add_option_hypervisor_openvz() {
  needs_kernel=

  vzconf_path=${vzconf_path:-}
  vzconf_dir=${vzconf_dir:-}
}

function configure_hypervisor() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] no such directory: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  echo "[INFO] ***** Configuring openvz-specific *****"
  configure_container ${chroot_dir}
}

##

function next_ctid() {
  local vz_conf_dir=${1:-/etc/vz/conf}

  local curid=$(ls ${vz_conf_dir}/ | egrep "^[0-9]*.conf$" | sort -r | head -1 | sed 's,\.conf$,,')

  case "${curid}" in
  ""|[0-9]|[0-9][0-9]|100)
    echo 101
    ;;
  *)
    echo $((${curid} + 1))
    ;;
  esac
}

function render_openvz_config() {
  cat <<'EOS'
#  Copyright (C) 2000-2011, Parallels, Inc. All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

# UBC parameters (in form of barrier:limit)
KMEMSIZE="unlimited"
LOCKEDPAGES="2048:2048"
PRIVVMPAGES="65536:69632"
SHMPAGES="21504:21504"
NUMPROC="unlimited"
PHYSPAGES="0:unlimited"
VMGUARPAGES="33792:unlimited"
OOMGUARPAGES="26112:unlimited"
NUMTCPSOCK="unlimited"
NUMFLOCK="188:206"
NUMPTY="16:16"
NUMSIGINFO="256:256"
TCPSNDBUF="unlimited"
TCPRCVBUF="1720320:2703360"
OTHERSOCKBUF="1126080:2097152"
DGRAMRCVBUF="262144:262144"
NUMOTHERSOCK="360:360"
DCACHESIZE="3409920:3624960"
NUMFILE="9312:9312"
AVNUMPROC="180:180"
NUMIPTENT="128:128"

# Disk quota parameters (in form of softlimit:hardlimit)
DISKSPACE="2G:2.2G"
DISKINODES="200000:220000"
QUOTATIME="0"

# CPU fair scheduler parameter
CPUUNITS="1000"
EOS
}

## controll openvz process

# render ....
# vzctl set 101 --name i-101 --save
# vzctl set 101 --cpus 1 --save
# mkdir /vz/root/101
# vzctl start i-101

function openvz_create() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  checkroot || return 1

  VEID=$(next_ctid)
  . ${vzconf_path:-/etc/vz/vz.conf}

  [[ -d "${VE_ROOT}"    ]] || mkdir -p ${VE_ROOT}
  [[ -d "${VE_PRIVATE}" ]] || mkdir -p ${VE_PRIVATE}

  render_openvz_config > ${vzconf_dir:-/etc/vz/conf}/${VEID}.conf

  shlog vzctl set ${VEID} --name ${name} --save
  shlog vzctl set ${VEID} --cpus 1 --save
  shlog vzctl set ${VEID} --privvmpage  65536 --save
  shlog vzctl set ${VEID} --vmguarpages 65536 --save

  echo "[INFO] You should deploy 'rootfs/' to '${VE_ROOT}/'."
  echo "[INFO] \$ rsync -aHA rootfs/ ${VE_PRIVATE}/"
}

function openvz_start() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog vzctl start ${name}
}

function openvz_stop() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog vzctl stop ${name}
}

function openvz_destroy() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog vzctl destroy ${name}
}

function openvz_console() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog vzctl console ${name}
}

function openvz_status() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog vzctl status ${name}
}

function openvz_list() {
  checkroot || return 1

  shlog vzlist
}
