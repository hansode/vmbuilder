# -*-Shell-script-*-
#
# description:
#  Linux Distribution
#
# requires:
#  bash
#

function add_option_distro_rhel5() {
  load_distro_driver rhel4

  distro_ver_latest=5.10

  case ${distro_ver} in
  5) distro_ver=${distro_ver_latest} ;;
  esac
}
