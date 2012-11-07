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

function add_option_distro_fedora17() {
  load_distro_driver fedora16

  gpgkey=https://fedoraproject.org/static/1ACA3465.txt
}
