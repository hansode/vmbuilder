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

function add_option_distro_fedora19() {
  load_distro_driver fedora18

  gpgkey=https://fedoraproject.org/static/FB4B18E6.txt
}
