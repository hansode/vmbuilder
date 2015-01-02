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

function add_option_distro_fedora21() {
  load_distro_driver fedora20

  gpgkey=https://getfedora.org/static/95A43F54.txt
}
