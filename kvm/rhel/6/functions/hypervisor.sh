# -*-Shell-script-*-
#
# description:
#  Hypervisor
#
# requires:
#  bash, basename
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
#  distro: add_option_distro, preflight_check_distro, install_kernel, install_bootloader, install_epel, install_addedpkgs, mount_proc
#          create_initial_user, install_authorized_keys
#          mount_dev, mount_sys, configure_networking, configure_mounting, configure_keepcache, configure_console
#

## depending on global variables

function add_option_hypervisor() {
  distro=${distro_name}-${distro_ver}_${distro_arch}
  distro_dir=${distro_dir:-$(pwd)/${distro}}

  copy=${copy:-}
  execscript=${execscript:-}
  firstboot=${firstboot:-}
  firstlogin=${firstlogin:-}
  raw=${raw:-./${distro}.raw}

  rootfs_dir=${rootfs_dir:-./rootfs}
  diskless=${diskless:-}

  chroot_dir=${chroot_dir:-/tmp/tmp$(date +%s)}

  viftab=${viftab:-}

  hypervisor=${hypervisor:-}
  case "${hypervisor}" in
  kvm|lxc|openvz)
    printf "[INFO] Hypervisor: %s\n" ${hypervisor}
    load_hypervisor_driver ${hypervisor}
    ;;
  *)
    echo "[ERROR] no mutch hypervisor ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2
    return 1
    ;;
  esac
}

function load_hypervisor_driver() {
  local driver_name=$1
  [[ -n "${driver_name}" ]] || { echo "[ERROR] Invalid argument: driver_name:${driver_name} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  local driver_path=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/hypervisor/${driver_name}.sh
  [[ -f "${driver_path}" ]] || { echo "[ERROR] no such driver: ${driver_path} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  . ${driver_path}
  add_option_hypervisor_${driver_name}
}

function preflight_check_hypervisor() {
  :
}

## vmdisk

function mount_ptab_root() {
  local disk_filename=$1 chroot_dir=$2
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
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
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
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
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  checkroot || return 1

  mount_ptab_root    ${disk_filename} ${chroot_dir}
  mount_ptab_nonroot ${disk_filename} ${chroot_dir}
}

function umount_ptab() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  checkroot || return 1

  umount_nonroot ${chroot_dir}
  umount_root    ${chroot_dir}
}

##

function run_copy() {
  local chroot_dir=$1 copy=$2
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -n "${copy}" ]] || return 0
  [[ -f "${copy}" ]] || { echo "[ERROR] The path to the copy directive is invalid: ${copy}. Make sure you are providing a full path. ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

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
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -n "${execscript}" ]] || return 0
  [[ -x "${execscript}" ]] || { echo "[WARN] cannot execute script: ${execscript} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 0; }

  printf "[INFO] Excecuting script: %s\n" ${execscript}
  [[ -n "${distro_arch}" ]] || add_option_distro

  setarch ${distro_arch} ${execscript} ${chroot_dir} || {
    echo "[ERROR] execscript failed: exitcode=$? ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2
    return 1
  }
}

function install_firstboot() {
  local chroot_dir=$1 firstboot=$2
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -n "${firstboot}"  ]] || return 0
  [[ -f "${firstboot}"  ]] || { echo "[ERROR] The path to the first-boot directive is invalid: ${firstboot}. Make sure you are providing a full path. ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  printf "[DEBUG] Installing firstboot script %s\n" ${firstboot}
  rsync -aHA ${firstboot} ${chroot_dir}/root/firstboot.sh
  chmod 0700 ${chroot_dir}/root/firstboot.sh

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
	touch /var/lock/subsys/local
	EOS
  chmod 755 ${chroot_dir}/etc/rc.d/rc.local
}

function install_firstlogin() {
  local chroot_dir=$1 firstlogin=$2
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -n "${firstlogin}" ]] || return 0
  [[ -f "${firstlogin}" ]] || { echo "[ERROR] The path to the first-login directive is invalid: ${firstlogin}. Make sure you are providing a full path. ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  printf "[DEBUG] Installing first login script %s\n" ${firstlogin}
  rsync -aHA ${firstlogin} ${chroot_dir}/root/firstlogin.sh
  chmod 0755 ${chroot_dir}/root/firstlogin.sh

  cp ${chroot_dir}/etc/bashrc ${chroot_dir}/etc/bashrc.orig
  cat <<-'EOS' >> ${chroot_dir}/etc/bashrc
	#execute firstlogin.sh only once
	if [ ! -e /root/firstlogin_done ]; then
	    if [ -e /root/firstlogin.sh ]; then
	        /root/firstlogin.sh
	    fi
	    # This part should not be necessary any more
	    # sudo dpkg-reconfigure -p critical console-setup &> /dev/null
	    sudo touch /root/firstlogin_done
	    # MEMO(first-login): should be changed previous attribute?
	    # sudo chmod 0550 ${chroot_dir}/root/
	fi
	EOS
  # MEMO(first-login): should be changed to access first-login script.
  chmod 0711 ${chroot_dir}/root/
}

function sync_os() {
  #
  # Synchronize directories
  #
  # **The argument order is depending on rsync**
  #
  local distro_dir=$1 chroot_dir=$2
  [[ -d "${distro_dir}" ]] || { echo "[ERROR] no such directory: ${distro_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] no such directory: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  checkroot || return 1

  rsync -aHA ${distro_dir}/ ${chroot_dir}
  sync
}

function configure_hypervisor() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] no such directory: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  # should be implemented in hypervisor-specific function file.
  :
}

function install_os() {
  local chroot_dir=$1 distro_dir=$2 disk_filename=$3
  [[ -d "${chroot_dir}"    ]] && { echo "[ERROR] already exists: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -d "${distro_dir}"    ]] || { echo "[ERROR] no such directory: ${distro_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -z "${diskless}" ]] && {
    # needs disk
    [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  } || {
    # diskless
    printf "[INFO] Diskless mode\n"
  }
  # install_kernel depends on distro_name.
  [[ -n "${distro_name}"   ]] || { echo "[ERROR] Invalid argument: distro_name:${distro_name} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  checkroot || return 1

  mkdir -p ${chroot_dir}
  [[ -n "${diskless}" ]] || {
    mount_ptab ${disk_filename} ${chroot_dir}
  }

  printf "[DEBUG] Installing OS to %s\n" ${chroot_dir}
  # ${distro_dir} -> ${chroot_dir}
  sync_os ${distro_dir} ${chroot_dir}

  mount_proc           ${chroot_dir}
  mount_dev            ${chroot_dir}

  # need to mount /sys to install grub2
  mount_sys            ${chroot_dir}

  # moved from distro in order to use cached distro dir
  create_initial_user     ${chroot_dir}
  install_authorized_keys ${chroot_dir}

  configure_networking ${chroot_dir}
  [[ -n "${diskless}" ]] || {
    configure_mounting ${chroot_dir} ${disk_filename}
  }
  configure_keepcache  ${chroot_dir}
  configure_console    ${chroot_dir}
  configure_hypervisor ${chroot_dir}
  install_kernel       ${chroot_dir}
  [[ -n "${diskless}" ]] || {
    install_bootloader ${chroot_dir} ${disk_filename}
  }
  install_epel         ${chroot_dir}
  install_addedpkgs    ${chroot_dir}
  run_copy             ${chroot_dir} ${copy}
  run_execscript       ${chroot_dir} ${execscript}
  install_firstboot    ${chroot_dir} ${firstboot}
  install_firstlogin   ${chroot_dir} ${firstlogin}

  [[ -n "${diskless}" ]] && {
    umount_nonroot ${chroot_dir}
  } || {
    umount_ptab    ${chroot_dir}
    rmdir          ${chroot_dir}
  }
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
