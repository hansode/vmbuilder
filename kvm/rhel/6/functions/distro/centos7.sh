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

function add_option_distro_centos7() {
  load_distro_driver rhel7
  load_distro_driver centos

  distro_ver_latest=7.0.1406

  case ${distro_ver} in
  7|7.0) distro_ver=${distro_ver_latest} ;;
  esac

  baseurl=${baseurl:-http://vault.centos.org/${distro_ver}/os/${basearch}}
  gpgkey=${gpgkey:-${baseurl}/RPM-GPG-KEY-CentOS-7}
}
