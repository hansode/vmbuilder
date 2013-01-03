# -*-Shell-script-*-
#
# description:
#  Hypervisor null
#
# requires:
#  bash
#
# imports:
#

function add_option_hypervisor_null() {
  needs_kernel=1
}

function configure_hypervisor() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] no such directory: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  echo "[INFO] ***** Configuring null-specific *****"
}
