# -*-Shell-script-*-
#
# description:
#  Linux Distribution
#
# requires:
#  bash
#

function add_option_distro_centos5() {
  distro_snake=CentOS
  baseurl=${baseurl:-http://ftp.riken.go.jp/pub/Linux/centos/${distro_ver}/os/${basearch}}
  gpgkey="${gpgkey:-${baseurl}/RPM-GPG-KEY-${distro_snake}-5}"

  preferred_filesystem=ext3
  preferred_initrd=initrd
}
