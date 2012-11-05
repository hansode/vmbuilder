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

function add_option_distro_fedora10() {
  load_distro_driver fedora9

  gpgkey="${baseurl}/RPM-GPG-KEY-fedora ${baseurl}/RPM-GPG-KEY-fedora-${distro_ver}-primary ${baseurl}/RPM-GPG-KEY-fedora-${basearch}"
}
