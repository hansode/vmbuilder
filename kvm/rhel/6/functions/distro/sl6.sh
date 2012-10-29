# -*-Shell-script-*-
#
# description:
#  Linux Distribution
#
# requires:
#  bash
#

function add_option_distro_sl6() {
  distro_snake="Scientific Linux"
  baseurl=${baseurl:-http://ftp.riken.go.jp/pub/Linux/scientific/${distro_ver}/${basearch}/os}
  gpgkey="${gpgkey:-${baseurl}/RPM-GPG-KEY-sl ${baseurl}/RPM-GPG-KEY-sl6}"
}
