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

function add_option_distro_fedora15() {
  baseurl=${baseurl:-http://ftp.riken.go.jp/pub/Linux/fedora/releases/${distro_ver}/Fedora/${basearch}/os}

  load_distro_driver fedora14
}
