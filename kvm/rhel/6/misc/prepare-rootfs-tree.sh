#!/bin/bash

#
set -e

args=
while [ $# -gt 0 ]; do
  arg="$1"
  case "${arg}" in
    --*=*)
      key=${arg%%=*}; key=${key##--}; key=${key//-/_}
      value=${arg##--*=}
      eval "${key}=\"${value}\""
      ;;
    *)
      args="${args} ${arg}"
      ;;
  esac
  shift
done


# check
[[ $UID -ne 0 ]] && {
  echo "ERROR: Run as root" >/dev/stderr
  exit 1
}

#
# vars
#
distro_arch=${distro_arch:-$(arch)}
case ${distro_arch} in
i*86)   basearch=i386; distro_arch=i686;;
x86_64) basearch=${distro_arch};;
esac

distro_ver=${distro_ver:-6.3}
distro_name=${distro_name:-centos}
distro=${distro_name}-${distro_ver}_${distro_arch}
distro_dir=${distro_dir:-`pwd`/${distro}}

[[ -f ${distro}.tar.gz ]] || curl -R -O http://dlc.wakame.axsh.jp.s3.amazonaws.com/demo/rootfs-tree/${distro}.tar.gz
[[ -d ${distro}        ]] || tar zxvpf ${distro}.tar.gz
