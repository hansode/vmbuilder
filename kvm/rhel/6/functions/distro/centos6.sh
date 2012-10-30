# -*-Shell-script-*-
#
# description:
#  Linux Distribution
#
# requires:
#  bash
#

function add_option_distro_centos6() {
  distro_snake=CentOS
  baseurl=${baseurl:-http://ftp.riken.go.jp/pub/Linux/centos/${distro_ver}/os/${basearch}}
  gpgkey="${gpgkey:-${baseurl}/RPM-GPG-KEY-${distro_snake}-6}"

  preferred_filesystem=ext4
}
