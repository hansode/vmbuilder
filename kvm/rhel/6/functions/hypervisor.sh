# -*-Shell-script-*-
#
# description:
#  Hypervisor
#
# requires:
#  bash
#  pwd, date
#  mount, umount
#  mkdir, rmdir
#  rsync, sync
#  egrep
#  setarch
#  cat, mv, chmod
#
# imports:
#  utils: checkroot
#  disk: xptabproc, mntpnt2path
#  distro: add_option_distro, preflight_check_distro, install_kernel, install_bootloader, mount_proc
#          mount_dev, mount_sys, configure_networking, configure_mounting, configure_keepcache
#

## depending on global variables

function add_option_hypervisor() {
  add_option_distro

  distro=${distro_name}-${distro_ver}_${distro_arch}
  distro_dir=${distro_dir:-$(pwd)/${distro}}

  max_mount_count=${max_mount_count:-37}
  interval_between_check=${interval_between_check:-180}

  rootsize=${rootsize:-4096}
  bootsize=${bootsize:-0}
  optsize=${optsize:-0}
  swapsize=${swapsize:-1024}
  homesize=${homesize:-0}
  usrsize=${usrsize:-0}
  varsize=${varsize:-0}
  tmpsize=${tmpsize:-0}

  xpart=${xpart:-}
  copy=${copy:-}
  execscript=${execscript:-}
  firstboot=${firstboot:-}
  raw=${raw:-./${distro}.raw}

  chroot_dir=${chroot_dir:-/tmp/tmp$(date +%s)}

  #domain=${domain:-}
  ip=${ip:-}
  mask=${mask:-}
  net=${net:-}
  bcast=${bcast:-}
  gw=${gw:-}
  dns=${dns:-}
  hostname=${hostname:-}

  nictab=${nictab:-}
  viftab=${viftab:-}
}

function load_hypervisor_driver() {
  local driver_name=$1
  [[ -n "${driver_name}" ]] || { echo "[ERROR] Invalid argument: driver_name:${driver_name} (hypervisor:${LINENO})" >&2; return 1; }

  local driver_path=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/hypervisor/${driver_name}.sh
  [[ -f "${driver_path}" ]] || { echo "[ERROR] no such driver: ${driver_path} (hypervisor:${LINENO})" >&2; return 1; }

  . ${driver_path}
}

function preflight_check_hypervisor() {
  :
}

## vmdisk

function mount_ptab_root() {
  local disk_filename=$1 chroot_dir=$2
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (hypervisor:${LINENO})" >&2; return 1; }
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (hypervisor:${LINENO})" >&2; return 1; }
  checkroot || return 1

  xptabproc <<'EOS'
    part_filename=$(mntpnt2path ${disk_filename} ${mountpoint})
    case "${mountpoint}" in
    root)
      printf "[DEBUG] Mounting %s\n" ${chroot_dir}
      mount ${part_filename} ${chroot_dir}
      ;;
    esac
EOS
}

function mount_ptab_nonroot() {
  local disk_filename=$1 chroot_dir=$2
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (hypervisor:${LINENO})" >&2; return 1; }
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (hypervisor:${LINENO})" >&2; return 1; }
  checkroot || return 1

  xptabproc <<'EOS'
    part_filename=$(mntpnt2path ${disk_filename} ${mountpoint})
    case "${mountpoint}" in
    root|swap) ;;
    *)
      printf "[DEBUG] Mounting %s\n" ${chroot_dir}${mountpoint}
      [[ -d "${chroot_dir}${mountpoint}" ]] || mkdir -p ${chroot_dir}${mountpoint}
      mount ${part_filename} ${chroot_dir}${mountpoint}
      ;;
    esac
EOS
}

function mount_ptab() {
  local disk_filename=$1 chroot_dir=$2
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (hypervisor:${LINENO})" >&2; return 1; }
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (hypervisor:${LINENO})" >&2; return 1; }
  checkroot || return 1

  mount_ptab_root    ${disk_filename} ${chroot_dir}
  mount_ptab_nonroot ${disk_filename} ${chroot_dir}
}

function umount_ptab() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (hypervisor:${LINENO})" >&2; return 1; }
  checkroot || return 1

  umount_nonroot ${chroot_dir}
  umount_root    ${chroot_dir}
}

##

function run_copy() {
  local chroot_dir=$1 copy=$2
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (hypervisor:${LINENO})" >&2; return 1; }
  [[ -n "${copy}" ]] || return 0
  [[ -f "${copy}" ]] || { echo "[ERROR] The path to the copy directive is invalid: ${copy}. Make sure you are providing a full path. (hypervisor:${LINENO})" >&2; return 1; }

  printf "[INFO] Copying files specified by copy in: %s\n" ${copy}
  while read line; do
    set ${line}
    [[ $# == 2 ]] || continue
    local destdir=${chroot_dir}$(dirname ${2})
    [[ -d "${destdir}" ]] || mkdir -p ${destdir}
    rsync -aHA ${1} ${chroot_dir}${2} || :
  done < <(egrep -v '^$' ${copy})
}

function run_execscript() {
  local chroot_dir=$1 execscript=$2
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (hypervisor:${LINENO})" >&2; return 1; }
  [[ -n "${execscript}" ]] || return 0
  [[ -x "${execscript}" ]] || { echo "[WARN] cannot execute script: ${execscript} (hypervisor:${LINENO})" >&2; return 0; }

  printf "[INFO] Excecuting script: %s\n" ${execscript}
  [[ -n "${distro_arch}" ]] || add_option_distro
  setarch ${distro_arch} ${execscript} ${chroot_dir}
}

function install_firstboot() {
  local chroot_dir=$1 firstboot=$2
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (hypervisor:${LINENO})" >&2; return 1; }
  [[ -n "${firstboot}"  ]] || return 0
  [[ -f "${firstboot}"  ]] || { echo "[ERROR] The path to the firstboot directive is invalid: ${firstboot}. Make sure you are providing a full path. (hypervisor:${LINENO})" >&2; return 1; }

  printf "[DEBUG] Installing firstboot script %s\n" ${firstboot}
  rsync -aHA ${firstboot} ${chroot_dir}/root/firstboot.sh
  chmod 755 ${chroot_dir}/root/firstboot.sh

  mv ${chroot_dir}/etc/rc.d/rc.local ${chroot_dir}/etc/rc.d/rc.local.orig
  cat <<-'EOS' > ${chroot_dir}/etc/rc.d/rc.local
	#!/bin/sh -e
	#execute firstboot.sh only once
	if [ ! -e /root/firstboot_done ]; then
	    if [ -e /root/firstboot.sh ]; then
	        /root/firstboot.sh
	    fi
	    touch /root/firstboot_done
	fi
	exit 0
	EOS
  chmod 755 ${chroot_dir}/etc/rc.d/rc.local
}

function sync_os() {
  #
  # Synchronize directories
  #
  # **The argument order is depending on rsync**
  #
  local distro_dir=$1 chroot_dir=$2
  [[ -d "${distro_dir}" ]] || { echo "[ERROR] no such directory: ${distro_dir} (hypervisor:${LINENO})" >&2; return 1; }
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] no such directory: ${chroot_dir} (hypervisor:${LINENO})" >&2; return 1; }
  checkroot || return 1

  rsync -aHA ${distro_dir}/ ${chroot_dir}
  sync
}

function install_os() {
  local chroot_dir=$1 distro_dir=$2 disk_filename=$3 keepcache=${4:-0} execscript=$5
  [[ -d "${chroot_dir}"    ]] && { echo "[ERROR] already exists: ${chroot_dir} (hypervisor:${LINENO})" >&2; return 1; }
  [[ -d "${distro_dir}"    ]] || { echo "[ERROR] no such directory: ${distro_dir} (hypervisor:${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (hypervisor:${LINENO})" >&2; return 1; }
  # install_kernel depends on distro_name.
  [[ -n "${distro_name}"   ]] || { echo "[ERROR] Invalid argument: distro_name:${distro_name} (hypervisor:${LINENO})" >&2; return 1; }
  checkroot || return 1

  mkdir -p ${chroot_dir}
  mount_ptab ${disk_filename} ${chroot_dir}

  printf "[DEBUG] Installing OS to %s\n" ${chroot_dir}
  # ${distro_dir} -> ${chroot_dir}
  sync_os ${distro_dir} ${chroot_dir}

  mount_proc           ${chroot_dir}
  mount_dev            ${chroot_dir}

  # need to mount /sys to install grub2
  mount_sys            ${chroot_dir}

  configure_networking ${chroot_dir}
  configure_mounting   ${chroot_dir} ${disk_filename}
  configure_keepcache  ${chroot_dir} ${keepcache}
  install_kernel       ${chroot_dir}
  install_bootloader   ${chroot_dir} ${disk_filename}
  run_copy             ${chroot_dir} ${copy}
  run_execscript       ${chroot_dir} ${execscript}
  install_firstboot    ${chroot_dir} ${firstboot}

  umount_ptab          ${chroot_dir}
  rmdir                ${chroot_dir}
}

##

function viftabinfo() {
  # format:
  #  [vif_name] [macaddr] [bridge_if]

  {
    [[ -n "${viftab}" ]] && [[ -f "${viftab}" ]] && {
      cat ${viftab}
    } || {
      local vif_name=${name:-rhel6}-${monitor_port:-4444}
      for i in $(seq 1 ${vif_num}); do
        local offset=$((${i} - 1)) suffix=
        [[ "${offset}" == 0 ]] && suffix= || suffix=.${offset}
        echo "${vif_name}${suffix} - ${brname:-br0}"
      done
    }
  } | egrep -v '^$|^#'
}

function viftabproc() {
  local blk="$(cat)"

  local index vif_name macaddr bridge_if
  while read index vif_name macaddr bridge_if; do
    eval "${blk}"
  done < <(viftabinfo | cat -n)
}

function gen_macaddr() {
  local offset=${1:-0}
  printf "%s:%s\n" ${vendor_id:-52:54:00} $(date --date "${offset} hour ago" +%H:%M:%S)
}
