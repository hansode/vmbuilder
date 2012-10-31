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

function add_option_distro_rhel6() {
  load_distro_driver rhel5

  preferred_filesystem=ext4
  preferred_initrd=initramfs
}
