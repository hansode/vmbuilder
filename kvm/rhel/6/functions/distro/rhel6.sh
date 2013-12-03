# -*-Shell-script-*-
#
# description:
#  Linux Distribution
#
# requires:
#  bash
#
# imports:
#  distro: load_distro_driver
#

function add_option_distro_rhel6() {
  load_distro_driver rhel5

  case ${distro_ver} in
  6) distro_ver=6.5 ;;
  esac

  preferred_filesystem=ext4
  preferred_initrd=initramfs
  preferred_rpmdb_hash_ver=9
}
