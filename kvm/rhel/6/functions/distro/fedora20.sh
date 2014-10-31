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

function add_option_distro_fedora20() {
  load_distro_driver fedora19

  gpgkey=https://fedoraproject.org/static/246110C1.txt
}
