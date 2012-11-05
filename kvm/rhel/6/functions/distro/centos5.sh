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

function add_option_distro_centos5() {
  load_distro_driver rhel5

  case ${distro_ver} in
  5) distro_ver=5.8 ;;
  esac

  baseurl=${baseurl:-http://ftp.riken.go.jp/pub/Linux/centos/${distro_ver}/os/${basearch}}
  gpgkey=${gpgkey:-${baseurl}/RPM-GPG-KEY-CentOS-5}
}
