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

function add_option_distro_centos6() {
  load_distro_driver rhel6
  load_distro_driver centos

  gpgkey=${gpgkey:-${baseurl}/RPM-GPG-KEY-CentOS-6}
}
