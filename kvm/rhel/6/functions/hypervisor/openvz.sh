# -*-Shell-script-*-
#
# description:
#  Hypervisor openvz
#
# requires:
#  bash
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
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] no such directory: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  echo "[INFO] ***** Configuring openvz-specific *****"
  configure_container ${chroot_dir}
}

function after_umount_nonroot() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  # http://www.powerpbx.org/content/are-you-sure-you-want-revert-revision-sat-12102011-1203

  local dev_path

  while read name mode type major minor; do
    for dev_path in dev etc/udev/devices; do
      [[ -d ${chroot_dir}/${dev_path} ]] || mkdir -p  ${chroot_dir}/${dev_path}
      [[ -a ${chroot_dir}/${dev_path}/${name} ]] || {
        mknod -m ${mode} ${chroot_dir}/${dev_path}/${name} ${type} ${major} ${minor}
      }
    done
  done < <(cat <<-EOS | egrep -v '^#|^$'
	# common
	null    666 c 1 3
	zero    666 c 1 5
	tty1    620 c 4 1
	tty2    620 c 4 2
	tty3    620 c 4 3
	tty4    620 c 4 4
	console 600 c 5 1
	# container
	full    666 c 1 7
	random  666 c 1 8
	urandom 666 c 1 9
	ptmx    666 c 5 2
	# openvz
	ram0 640 b 1  0
	mem  640 c 1  1
	kmem 600 c 1  2
	port 640 c 1  4
	core 600 c 1  6
	kmsg 600 c 1 11
	# pty
	ptyp0 666 c 2 0
	ptyp1 666 c 2 1
	ptyp2 666 c 2 2
	ptyp3 666 c 2 3
	ptyp4 666 c 2 4
	ptyp5 666 c 2 5
	ptyp6 666 c 2 6
	ptyp7 666 c 2 7
	ptya0 666 c 2 176
	ptya1 666 c 2 177
	ptya2 666 c 2 178
	ptya3 666 c 2 179
	ptya4 666 c 2 180
	ptya5 666 c 2 181
	ptya6 666 c 2 182
	ptya7 666 c 2 183
	ptya8 666 c 2 184
	ptya9 666 c 2 185
	ptyaa 666 c 2 186
	ptyab 666 c 2 187
	ptyac 666 c 2 188
	ptyad 666 c 2 189
	ptyae 666 c 2 190
	ptyaf 666 c 2 181
	# tty
	ttyp0 666 c 3 0
	ttyp1 666 c 3 1
	ttyp2 666 c 3 2
	ttyp3 666 c 3 3
	ttyp4 666 c 3 4
	ttyp5 666 c 3 5
	ttyp6 666 c 3 6
	ttyp7 666 c 3 7
	ttya0 666 c 3 176
	ttya1 666 c 3 177
	ttya2 666 c 3 178
	ttya3 666 c 3 179
	ttya4 666 c 3 180
	ttya5 666 c 3 181
	ttya6 666 c 3 182
	ttya7 666 c 3 183
	ttya8 666 c 3 184
	ttya9 666 c 3 185
	ttyaa 666 c 3 186
	ttyab 666 c 3 187
	ttyac 666 c 3 188
	ttyad 666 c 3 189
	ttyae 666 c 3 190
	ttyaf 666 c 3 191
	EOS
	# loop
	for i in {0..127}; do
	  echo loop${i} 600 b 7 ${i}
	done
	)

  for dev_path in dev etc/udev/devices; do
    ln -s /proc/self/fd   ${chroot_dir}/${dev_path}/fd
    ln -s /proc/self/fd/0 ${chroot_dir}/${dev_path}/stdin
    ln -s /proc/self/fd/1 ${chroot_dir}/${dev_path}/stdout
    ln -s /proc/self/fd/2 ${chroot_dir}/${dev_path}/stderr
  done
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
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
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
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog vzctl start ${name}
}

function openvz_stop() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog vzctl stop ${name}
}

function openvz_destroy() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog vzctl destroy ${name}
}

function openvz_console() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog vzctl console ${name}
}

function openvz_status() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog vzctl status ${name}
}

function openvz_list() {
  checkroot || return 1

  shlog vzlist
}
