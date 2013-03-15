# -*-Shell-script-*-
#
# description:
#  Hypervisor lxc
#
# requires:
#  bash,
#  cat
#
# imports:
#  utils: shlog
#  hypervisor: configure_container, viftabproc
#

function add_option_hypervisor_lxc() {
  needs_kernel=

  brname=${brname:-br0}

  mem_size=${mem_size:-1024}
  cpu_num=${cpu_num:-1}

  vif_num=${vif_num:-1}
  viftab=${viftab:-}

  rootfs_dir=${rootfs_dir:-}

  vendor_id=${vendor_id:-52:54:00}
}

function configure_hypervisor() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] no such directory: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  echo "[INFO] ***** Configuring lxc-specific *****"
  configure_container ${chroot_dir}

  prevent_plymouth_starting ${chroot_dir}
}

function render_lxc_config() {
  local abs_rootfs_dir=$(expand_path ${rootfs_dir})

  cat <<-EOS
	lxc.utsname = ${hostname:-localhost}
	lxc.tty = 6
	#lxc.pts = 1024
	lxc.network.type = veth
	lxc.network.flags = up
	lxc.network.link = ${brname}
	lxc.network.name = eth0
	lxc.network.mtu = 1500
	lxc.network.hwaddr = $(gen_macaddr)
	lxc.rootfs = ${abs_rootfs_dir}
	lxc.rootfs.mount = ${abs_rootfs_dir}

	#lxc.mount.entry = devpts ${abs_rootfs_dir}/dev/pts                devpts  gid=5,mode=620  0 0
	lxc.mount.entry = proc   ${abs_rootfs_dir}/proc                   proc    defaults        0 0
	lxc.mount.entry = sysfs  ${abs_rootfs_dir}/sys                    sysfs   defaults        0 0
	
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
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  local lxc_config_path=$(pwd)/lxc.conf
  render_lxc_config > ${lxc_config_path}
  shlog lxc-create -f ${lxc_config_path} -n ${name}
}

function lxc_start() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog lxc-start -n ${name} -d -l DEBUG -o $(pwd)/lxc.log
}

function lxc_stop() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog lxc-stop -n ${name}
}

function lxc_destroy() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog lxc-destroy -n ${name}
}

function lxc_info() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog lxc-info -n ${name}
}

function lxc_console() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog lxc-console -n ${name}
}
