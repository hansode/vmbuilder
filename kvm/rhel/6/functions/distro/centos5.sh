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

  distro_snake=CentOS

  baseurl=${baseurl:-http://ftp.riken.go.jp/pub/Linux/centos/${distro_ver}/os/${basearch}}
  gpgkey=${gpgkey:-${baseurl}/RPM-GPG-KEY-${distro_snake}-5}
}
