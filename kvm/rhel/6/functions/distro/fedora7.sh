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

function add_option_distro_fedora7() {
  load_distro_driver fedora

  baseurl=${baseurl:-http://archive.fedoraproject.org/pub/archive/fedora/linux/releases/${distro_ver}/Everything/${basearch}/os}
  gpgkey=${gpgkey:-${baseurl}/RPM-GPG-KEY ${baseurl}/RPM-GPG-KEY-fedora}

  preferred_filesystem=ext3
  preferred_initrd=initrd
  preferred_grub=grub
}
