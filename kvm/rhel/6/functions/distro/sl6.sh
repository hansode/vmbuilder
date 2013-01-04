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

function add_option_distro_sl6() {
  load_distro_driver rhel6
  load_distro_driver sl

  baseurl=${baseurl:-http://ftp.riken.go.jp/pub/Linux/scientific/${distro_ver}/${basearch}/os}
  gpgkey="${gpgkey:-${baseurl}/RPM-GPG-KEY-sl ${baseurl}/RPM-GPG-KEY-sl6}"
}
