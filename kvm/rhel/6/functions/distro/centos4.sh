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

function add_option_distro_centos4() {
  load_distro_driver rhel4
  load_distro_driver centos

  baseurl=${baseurl:-http://vault.centos.org/${distro_ver}/os/${basearch}}
  gpgkey=${gpgkey:-${baseurl}/RPM-GPG-KEY-centos4 ${baseurl}/RPM-GPG-KEY}
}
