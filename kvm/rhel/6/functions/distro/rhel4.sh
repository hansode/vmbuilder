# -*-Shell-script-*-
#
# description:
#  Linux Distribution
#
# requires:
#  bash
#

function add_option_distro_rhel4() {
  load_distro_driver rhel

  case ${distro_ver} in
  4) distro_ver=4.9 ;;
  esac

  preferred_filesystem=ext3
  preferred_initrd=initrd
  preferred_rpmdb_hash_ver=8
}
