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
  load_distro_driver centos

  baseurl=${baseurl:-http://ftp.tsukuba.wide.ad.jp/Linux/centos/${distro_ver}/os/${basearch}}
  gpgkey=${gpgkey:-${baseurl}/RPM-GPG-KEY-CentOS-5}
}
