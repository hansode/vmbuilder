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
  name=${name:-rhel6}

  image_format=${image_format:-raw}
  image_file=${image_file:-${name}.${image_format}}
  image_path=${image_path:-${image_file}}
}

function configure_hypervisor() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] no such directory: ${chroot_dir} (hypervisor/lxc:${LINENO})" >&2; return 1; }

  echo "[INFO] ***** Configuring openvz-specific *****"
  configure_container ${chroot_dir}
}
