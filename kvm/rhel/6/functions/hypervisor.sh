# -*-Shell-script-*-
#
# description:
#  Hypervisor
#
# requires:
#  bash
#  mount, umount
#  mkdir, rmdir
#  rsync, sync
#  setarch
#
# imports:
#  utils: checkroot
#  disk: xptabproc, mntpnt2path
#  distro: add_option_distro, preflight_check_distro, install_kernel, install_bootloader, configure_networking, configure_mounting, configure_keepcache
#

## depending on global variables

function add_option_hypervisor() {
  add_option_distro

  distro=${distro_name}-${distro_ver}_${distro_arch}
  distro_dir=${distro_dir:-${abs_dirname}/${distro}}

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
  execscript=${execscript:-}
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
}

function preflight_check_hypervisor() {
  :
}


## vmdisk

function mount_ptab_root() {
  local disk_filename=$1 chroot_dir=$2
  [[ -a "${disk_filename}" ]] || { echo "file not found: ${disk_filename} (hypervisor:${LINENO})" >&2; return 1; }
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (hypervisor:${LINENO})" >&2; return 1; }
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
  [[ -a "${disk_filename}" ]] || { echo "file not found: ${disk_filename} (hypervisor:${LINENO})" >&2; return 1; }
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (hypervisor:${LINENO})" >&2; return 1; }
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
  [[ -a "${disk_filename}" ]] || { echo "file not found: ${disk_filename} (hypervisor:${LINENO})" >&2; return 1; }
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (hypervisor:${LINENO})" >&2; return 1; }
  checkroot || return 1

  mount_ptab_root    ${disk_filename} ${chroot_dir}
  mount_ptab_nonroot ${disk_filename} ${chroot_dir}
}

function umount_ptab() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (hypervisor:${LINENO})" >&2; return 1; }
  checkroot || return 1

  umount_nonroot ${chroot_dir}
  umount_root    ${chroot_dir}
}

##

function run_execscript() {
  local chroot_dir=$1 execscript=$2
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (hypervisor:${LINENO})" >&2; return 1; }
  [[ -n "${execscript}" ]] || return 0
  [[ -x "${execscript}" ]] || { echo "cannot execute script: ${execscript} (hypervisor:${LINENO})" >&2; return 0; }

  printf "[INFO] Excecuting script: %s\n" ${execscript}
  [[ -n "${distro_arch}" ]] || add_option_distro
  setarch ${distro_arch} ${execscript} ${chroot_dir}
}

function sync_os() {
  #
  # Synchronize directories
  #
  # **The argument order is depending on rsync**
  #
  local distro_dir=$1 chroot_dir=$2
  [[ -d "${distro_dir}" ]] || { echo "no such directory: ${distro_dir} (hypervisor:${LINENO})" >&2; exit 1; }
  [[ -d "${chroot_dir}" ]] || { echo "no such directory: ${chroot_dir} (hypervisor:${LINENO})" >&2; exit 1; }
  checkroot || return 1

  rsync -aHA ${distro_dir}/ ${chroot_dir}
  sync
}

function install_os() {
  local chroot_dir=$1 distro_dir=$2 disk_filename=$3 keepcache=${4:-0} execscript=$5
  [[ -d "${chroot_dir}" ]] && { echo "already exists: ${chroot_dir} (hypervisor:${LINENO})" >&2; return 1; }
  [[ -d "${distro_dir}" ]] || { echo "no such directory: ${distro_dir} (hypervisor:${LINENO})" >&2; exit 1; }
  [[ -a "${disk_filename}" ]] || { echo "file not found: ${disk_filename} (hypervisor:${LINENO})" >&2; return 1; }
  # install_kernel depends on distro_short.
  [[ -n "${distro_short}" ]] || { echo "[ERROR] Invalid argument: distro_short:${distro_short} (hypervisor:${LINENO})" >&2; return 1; }
  checkroot || return 1

  mkdir -p ${chroot_dir}
  mount_ptab ${disk_filename} ${chroot_dir}

  printf "[DEBUG] Installing OS to %s\n" ${chroot_dir}
  # ${distro_dir} -> ${chroot_dir}
  sync_os ${distro_dir} ${chroot_dir}

  mount_proc           ${chroot_dir}
  mount_dev            ${chroot_dir}
  configure_networking ${chroot_dir}
  configure_mounting   ${chroot_dir} ${disk_filename}
  configure_keepcache  ${chroot_dir} ${keepcache}
  configure_selinux    ${chroot_dir} ${selinux}
  set_timezone         ${chroot_dir}
  install_kernel       ${chroot_dir}
  install_bootloader   ${chroot_dir} ${disk_filename}
  run_execscript       ${chroot_dir} ${execscript}

  umount_ptab          ${chroot_dir}
  rmdir                ${chroot_dir}
}
