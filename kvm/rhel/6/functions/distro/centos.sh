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

function add_option_distro_centos() {
  yumrepo=base

  local baseurl_prefix=http://vault.centos.org
  if [[ "${distro_ver}" == "${distro_ver_latest}" ]]; then
    baseurl_prefix=http://ftp.riken.jp/pub/Linux/centos
  fi
  baseurl=${baseurl:-${baseurl_prefix}/${distro_ver}/os/${basearch}}
}
