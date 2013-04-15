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
#  distro: add_option_distro, preflight_check_distro, install_kernel, install_bootloader, install_epel, install_addedpkgs, mount_proc
#          create_initial_user, install_authorized_keys
#          mount_dev, mount_sys, configure_networking, configure_mounting, configure_keepcache
#          configure_hypervisor, configure_selinux
#          configure_sshd_password_authentication, configure_sshd_gssapi_authentication, configure_sshd_permit_root_login, configure_sudo_requiretty, configure_sshd_use_dns
#          run_copies, xsync_dir, run_execscripts, run_xexecscripts, install_firstboot, install_firstlogin, convert_rpmdb_hash, clean_packages, cleanup_distro
#

## depending on global variables

function add_option_hypervisor() {
  viftab=${viftab:-}

  hypervisor=${hypervisor:-}
  case "${hypervisor}" in
  null|kvm|lxc|openvz)
    load_hypervisor_driver ${hypervisor}
    ;;
  *)
    echo "[ERROR] no mutch hypervisor (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
    return 1
    ;;
  esac
}

function load_hypervisor_driver() {
  local driver_name=$1
  [[ -n "${driver_name}" ]] || { echo "[ERROR] Invalid argument: driver_name:${driver_name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  local driver_path=$(cd ${BASH_SOURCE[0]%/*} && pwd)/hypervisor/${driver_name}.sh
  [[ -f "${driver_path}" ]] || { echo "[ERROR] no such driver: ${driver_path} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  . ${driver_path}
  add_option_hypervisor_${driver_name}
}

function preflight_check_hypervisor() {
  :
}

## vmdisk

function mount_ptab_root() {
  local disk_filename=$1 chroot_dir=$2
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
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
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
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
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  mount_ptab_root    ${disk_filename} ${chroot_dir}
  mount_ptab_nonroot ${disk_filename} ${chroot_dir}
}

function umount_ptab() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  umount_nonroot ${chroot_dir}
  umount_root    ${chroot_dir}
}

##

function sync_os() {
  #
  # Synchronize directories
  #
  # **The argument order is depending on rsync**
  #
  local distro_dir=$1 chroot_dir=$2
  [[ -d "${distro_dir}" ]] || { echo "[ERROR] no such directory: ${distro_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] no such directory: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  rsync -aHA ${distro_dir}/ ${chroot_dir}
  sync
}

function configure_hypervisor() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] no such directory: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  # should be implemented in hypervisor-specific function file.
  :
}

function install_os() {
  local chroot_dir=$1 distro_dir=$2 disk_filename=$3
  [[ -d "${chroot_dir}"    ]] && { echo "[ERROR] already exists: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -d "${distro_dir}"    ]] || { echo "[ERROR] no such directory: ${distro_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  local needs_bootloader=1
  [[ -z "${diskless}" ]] && {
    # needs disk
    [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  } || {
    # diskless
    printf "[INFO] Diskless mode\n"
    needs_bootloader=
  }
  # install_kernel depends on distro_name.
  [[ -n "${distro_name}"   ]] || { echo "[ERROR] Invalid argument: distro_name:${distro_name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
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
  set_timezone            ${chroot_dir}

  configure_networking ${chroot_dir}
  [[ -n "${diskless}" ]] || {
    configure_mounting ${chroot_dir} ${disk_filename}
  }
  configure_keepcache  ${chroot_dir}
  configure_hypervisor ${chroot_dir}
  configure_selinux    ${chroot_dir}

  [[ -n "${needs_kernel}" ]] && {
    install_kernel     ${chroot_dir}
  } || {
    needs_bootloader=
  }
  [[ -z "${needs_bootloader}" ]] || {
    install_bootloader ${chroot_dir} ${disk_filename}
  }
  configure_sshd_password_authentication ${chroot_dir} ${sshd_passauth}
  configure_sshd_gssapi_authentication   ${chroot_dir} ${sshd_gssapi_auth}
  configure_sshd_permit_root_login       ${chroot_dir} ${sshd_permit_root_login}
  configure_sshd_use_dns                 ${chroot_dir} ${sshd_use_dns}
  configure_sudo_requiretty              ${chroot_dir} ${sudo_requiretty}

  install_epel         ${chroot_dir}
  install_addedpkgs    ${chroot_dir}
  convert_rpmdb_hash   ${chroot_dir}
  clean_packages       ${chroot_dir}
  run_copies           ${chroot_dir} ${copy}
  xsync_dir            ${chroot_dir} ${copydir}
  run_execscripts      ${chroot_dir} ${execscript}
  run_xexecscripts     ${chroot_dir} ${xexecscript}
  install_firstboot    ${chroot_dir} ${firstboot}
  install_firstlogin   ${chroot_dir} ${firstlogin}

  cleanup_distro       ${chroot_dir}

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
