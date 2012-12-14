# -*-Shell-script-*-
#
# description:
#  Hypervisor lxc
#
# requires:
#  bash
#
# imports:
#  utils: shlog
#  hypervisor: viftabproc
#

function add_option_hypervisor_lxc() {
  name=${name:-rhel6}

  image_format=${image_format:-raw}
  image_file=${image_file:-${name}.${image_format}}
  image_path=${image_path:-${image_file}}

  brname=${brname:-br0}

  mem_size=${mem_size:-1024}
  cpu_num=${cpu_num:-1}

  vif_num=${vif_num:-1}
  viftab=${viftab:-}

  vendor_id=${vendor_id:-52:54:00}

  rootfs_dir=${rootfs_dir:-$(pwd)/rootfs}
}

function render_lxc_config() {
	cat <<-EOS
	lxc.utsname = ${hostname:-localhost}
	lxc.tty = 6
	lxc.pts = 1024
	lxc.network.type = veth
	lxc.network.flags = up
	lxc.network.link = ${brname}
	lxc.network.name = eth0
	lxc.network.mtu = 1500
	#if $mac
	lxc.network.hwaddr = $(gen_macaddr)
	#end if
	lxc.rootfs = ${rootfs_dir}
	
	# /dev/null and zero
	lxc.cgroup.devices.allow = c 1:3 rwm
	lxc.cgroup.devices.allow = c 1:5 rwm
	
	# consoles
	lxc.cgroup.devices.allow = c 5:1 rwm
	lxc.cgroup.devices.allow = c 5:0 rwm
	lxc.cgroup.devices.allow = c 4:0 rwm
	lxc.cgroup.devices.allow = c 4:1 rwm
	
	# /dev/{,u}random
	lxc.cgroup.devices.allow = c 1:9 rwm
	lxc.cgroup.devices.allow = c 1:8 rwm
	lxc.cgroup.devices.allow = c 136:* rwm
	lxc.cgroup.devices.allow = c 5:2 rwm
	
	# rtc
	lxc.cgroup.devices.allow = c 254:0 rwm
	EOS
}

## controll lxc process

function lxc_create() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (hypervisor/kvm:${LINENO})" >&2; return 1; }
  checkroot || return 1

  local lxc_config_path=$(pwd)/lxc.conf
  render_lxc_config > ${lxc_config_path}
  shlog lxc-create -f ${lxc_config_path} -n ${name}
}

function lxc_start() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (hypervisor/kvm:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog lxc-start -n ${name} -l DEBUG -o $(pwd)/lxc.log
}

function lxc_stop() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (hypervisor/kvm:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog lxc-stop -n ${name}
}

function lxc_destroy() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (hypervisor/kvm:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog lxc-destroy -n ${name}
}

function lxc_info() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (hypervisor/lxc:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog lxc-info --name ${name}
}
