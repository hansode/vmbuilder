# -*-Shell-script-*-
#
# description:
#  The VM
#
# requires:
#  bash
#  rm
#
# imports:
#  utils: is_dev, checkroot
#  mbr: rmmbr
#  disk: xptabinfo, mkdisk, mkptab, mapptab, mkfsdisk, unmapptab
#  distro: build_chroot
#  hypervisor: preflight_check_hypervisor, install_os, umount_ptab
#

##

function trap_vm() {
  local disk_filename=$1 chroot_dir=$2
  [[ -d "${chroot_dir}" ]] && umount_ptab ${chroot_dir} || :
  is_dev ${disk_filename} || {
    unmapptab ${disk_filename}
    # TODO
    # * don't delete raw file in this implement.
    # * need to improve trap/signals
    #
    # rm -f ${disk_filename}
  }
}

function create_vm() {
  checkroot
  add_option_hypervisor
  preflight_check_hypervisor
  [[ -d "${distro_dir}" ]] || build_chroot ${distro_dir}

  trap 'exit 1'  HUP INT PIPE QUIT TERM
  trap "trap_vm ${raw} ${chroot_dir}" EXIT

  is_dev ${raw} && {
    rmmbr ${raw}
  } || {
    [[ -f "${raw}" ]] && rm -f ${raw}
    local totalsize=$(xptabinfo | awk 'BEGIN {sum = 0} {sum += $2} END {print sum}')
    printf "[INFO] Creating disk image: \"%s\" of size: %dMB\n" ${raw} ${totalsize}
    mkdisk ${raw} ${totalsize}
  }
  mkptab  ${raw}
  is_dev ${raw} || {
    printf "[INFO] Creating loop devices corresponding to the created partitions\n"
    mapptab ${raw}
  }
  mkfsdisk ${raw}
  install_os ${chroot_dir} ${distro_dir} ${raw} ${keepcache} ${execscript}
  is_dev ${raw} || {
    printf "[INFO] Deleting loop devices\n"
    unmapptab ${raw}
  }
  printf "[INFO] Generated => %s\n" ${raw}
  printf "[INFO] Complete!\n"
}
