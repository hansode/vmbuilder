# -*-Shell-script-*-
#
# description:
#  Linux Distribution
#
# requires:
#  bash
#

function add_option_distro_rhel5() {
  baseurl=${baseurl:-}
  gpgkey=${gpgkey:-}

  preferred_filesystem=ext3
  preferred_initrd=initrd
}
