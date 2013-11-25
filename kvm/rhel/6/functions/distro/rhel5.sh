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

  case ${distro_ver} in
  5) distro_ver=5.10 ;;
  esac
}
