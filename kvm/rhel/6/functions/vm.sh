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
#  utils: checkroot
#  mbr: rmmbr
#  disk: add_option_disk, is_dev, sum_disksize, mkdisk, mkptab, mapptab, mkfsdisk, unmapptab
#  distro: add_option_distro, build_chroot, preferred_filesystem, trap_distro
#  hypervisor: add_option_hypervisor, preflight_check_hypervisor, install_os, umount_ptab
#

##

function trap_vm() {
  local disk_filename=$1 chroot_dir=$2
  [[ -d "${chroot_dir}" ]] && umount_ptab ${chroot_dir} || :
  checkroot || return 1

  echo "[DEBUG] trap_vm fired"

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
  checkroot || return 1

  add_option_distro
  add_option_hypervisor
  add_option_disk
  preflight_check_hypervisor
  [[ -d "${distro_dir}" ]] || build_chroot ${distro_dir}

  local disk_filename=${raw}
  case "${diskless}" in
  1) create_vm_tree ${rootfs_dir}    ;;
  *) create_vm_disk ${disk_filename} ;;
  esac

  printf "[INFO] Complete!\n"
}

function create_vm_disk() {
  local disk_filename=$1
  [[ -a "${disk_filename}" ]] && { echo "[WARN] already exists: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})"; } || :
  checkroot || return 1

  trap "trap_vm ${disk_filename} ${chroot_dir}" ERR

  is_dev ${disk_filename} && {
    rmmbr ${disk_filename}
  } || {
    [[ -f "${disk_filename}" ]] && rm -f ${disk_filename}
    local totalsize=$(sum_disksize)
    printf "[INFO] Creating disk image: \"%s\" of size: %dMB\n" ${disk_filename} ${totalsize}
    mkdisk ${disk_filename} ${totalsize}
  }

  mkptab ${disk_filename}
  is_dev ${disk_filename} || {
    printf "[INFO] Creating loop devices corresponding to the created partitions\n"
    mapptab ${disk_filename}
  }

  mkfsdisk ${disk_filename} $(preferred_filesystem)

  (
    # execute sub-shell in order to fire trap
    install_os ${chroot_dir} ${distro_dir} ${disk_filename}
  )

  is_dev ${disk_filename} || {
    printf "[INFO] Deleting loop devices\n"
    unmapptab ${disk_filename}
  }

  printf "[INFO] Generated => %s\n" ${disk_filename}
}

function create_vm_tree() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] && { echo "[WARN] ${chroot_dir} already exists (${BASH_SOURCE[0]##*/}:${LINENO})"; } || :
  checkroot || return 1

  trap "trap_distro ${chroot_dir}" ERR

  (
    # execute sub-shell in order to fire trap
    install_os ${chroot_dir} ${distro_dir}
  )
  printf "[INFO] Built => %s\n" ${chroot_dir}
}
