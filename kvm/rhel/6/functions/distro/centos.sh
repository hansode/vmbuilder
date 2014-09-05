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

function add_option_distro_centos() {
  yumrepo=base

  baseurl=${baseurl:-http://vault.centos.org/${distro_ver}/os/${basearch}}
}
