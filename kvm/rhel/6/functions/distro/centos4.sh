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

function add_option_distro_centos4() {
  load_distro_driver rhel4

  case ${distro_ver} in
  4) distro_ver=4.9 ;;
  esac

  baseurl=${baseurl:-http://vault.centos.org/${distro_ver}/os/${basearch}}
  gpgkey=${gpgkey:-${baseurl}/RPM-GPG-KEY-centos4 ${baseurl}/RPM-GPG-KEY}
}
