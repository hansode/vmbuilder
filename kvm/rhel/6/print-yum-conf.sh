#!/bin/bash
#
# OPTIONS
#        --distro-arch=[x86_64 | i686]
#        --distro-name=[centos | sl]
#        --distro-ver=[6 | 6.0 | 6.2 | ... ]
#
set -e

args=
while [ $# -gt 0 ]; do
  arg="$1"
  case "${arg}" in
    --*=*)
      key=${arg%%=*}; key=$(echo ${key##--} | tr - _)
      value=${arg##--*=}
      eval "${key}=\"${value}\""
      ;;
    *)
      args="${args} ${arg}"
      ;;
  esac
  shift
done

#
# vars
#
distro_arch=${distro_arch:-$(arch)}
case ${distro_arch} in
i*86)   basearch=i386; distro_arch=i686;;
x86_64) basearch=${distro_arch};;
esac

distro_ver=${distro_ver:-6}
distro_name=${distro_name:-centos}

# validate
case ${distro_name} in
  centos)
    distro_short=centos
    distro_snake=CentOS
    baseurl=http://ftp.riken.go.jp/pub/Linux/centos/${distro_ver}/os/${basearch}
    case ${distro_ver} in
    6|6.*)
      gpgkey="${baseurl}/RPM-GPG-KEY-${distro_snake}-6"
      ;;
    esac
    ;;
  sl|scientific|scientificlinux)
    distro_short=sl
    distro_snake="Scientific Linux"
    baseurl=http://ftp.riken.go.jp/pub/Linux/scientific/${distro_ver}/${basearch}/os
    case ${distro_ver} in
    6|6.*)
      gpgkey="${baseurl}/RPM-GPG-KEY-sl ${baseurl}/RPM-GPG-KEY-sl6"
      ;;
    esac
    ;;
  *)
    echo "no mutch distro" >&2
    exit 1;
esac

# yum
cat <<EOS
[chrooted-base]
name=${distro_snake} ${distro_ver} - ${basearch}
baseurl=${baseurl}
enabled=1
gpgcheck=1
gpgkey=${gpgkey}
EOS
