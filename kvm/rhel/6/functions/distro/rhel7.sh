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

function add_option_distro_rhel7() {
  load_distro_driver rhel6

  distro_ver_latest=7.1.1503

  case ${distro_ver} in
  7|7.1) distro_ver=${distro_ver_latest} ;;
  esac

  preferred_grub=grub2

 #baseurl=http://ftp.redhat.com/redhat/rhel/beta/7/${basearch}/os
 #gpgkey="${baseurl}/RPM-GPG-KEY-redhat-beta ${baseurl}/RPM-GPG-KEY-redhat-release"
}
