#!/bin/bash
#
# OPTIONS
#        --distro-arch=[x86_64 | i686]
#        --distro-name=[centos | sl]
#        --distro-ver=[6 | 6.0 | 6.2 | ... ]
#        --batch=1
#        --chroot-dir=/path/to/rootfs
#        --keepcache=1
#        --debug=1
#
set -e

## private functions

function extract_args() {
  CMD_ARGS=
  for arg in $*; do
    case $arg in
      --*=*)
        key=${arg%%=*}; key=$(echo ${key##--} | tr - _)
        value=${arg##--*=}
        eval "${key}=\"${value}\""
        ;;
      *)
        CMD_ARGS="${CMD_ARGS} ${arg}"
        ;;
    esac
  done
  # trim
  CMD_ARGS=${CMD_ARGS%% }
  CMD_ARGS=${CMD_ARGS## }
}

function build_vers() {
  debug=${debug:-}
  [ -z ${debug} ] || set -x

  distro_arch=${distro_arch:-$(arch)}
  case "${distro_arch}" in
  i*86)   basearch=i386; distro_arch=i686;;
  x86_64) basearch=${distro_arch};;
  esac

  distro_ver=${distro_ver:-6.3}
  distro_name=${distro_name:-centos}
  root_dev=${root_dev:-/dev/sda1}

  case "${distro_name}" in
  centos)
    distro_short=centos
    distro_snake=CentOS
    baseurl=http://ftp.riken.go.jp/pub/Linux/centos/${distro_ver}/os/${basearch}
    case "${distro_ver}" in
    6|6.*)
      gpgkey="${baseurl}/RPM-GPG-KEY-${distro_snake}-6"
      ;;
    esac
    ;;
  sl|scientific|scientificlinux)
    distro_short=sl
    distro_snake="Scientific Linux"
    baseurl=http://ftp.riken.go.jp/pub/Linux/scientific/${distro_ver}/${basearch}/os
    case "${distro_ver}" in
    6|6.*)
      gpgkey="${baseurl}/RPM-GPG-KEY-sl ${baseurl}/RPM-GPG-KEY-sl6"
      ;;
    esac
    ;;
  esac

  chroot_dir=${chroot_dir:-${abs_path}/${distro_short}-${distro_ver}_${distro_arch}}

  keepcache=${keepcache:-0}
  # keepcache should be [ 0 | 1 ]
  case "${keepcache}" in
  [01]) ;;
  *)    keepcache=0 ;;
  esac

  repo=${abs_path}/yum-${distro_short}-${distro_ver}.repo
  yum_cmd="
    yum \
     -c ${repo} \
     --disablerepo="\*" \
     --enablerepo="${distro_short}" \
     --installroot=${chroot_dir} \
     -y
  "
}

function checkroot() {
  [[ $UID -ne 0 ]] && {
    echo "[ERROR] Must run as root." >&2
    return 1
  } || :
}

### prepare

extract_args $*

### read-only variables

readonly abs_path=$(cd $(dirname $0) && pwd)

## main

build_vers
checkroot
cmd="$(echo ${CMD_ARGS} | sed "s, ,\n,g" | head -1)"

which yum >/dev/null 2>&1 || {
  echo "[error] command not found: 'yum'" >&2
  exit 1;
}

# validate
case "${distro_name}" in
"")
  echo "no mutch distro" >&2
  exit 1;
esac

# dump vars
cat <<EOS
--------------------
distro_arch: ${distro_arch}
distro_name: ${distro_name} ${distro_snake}
distro_ver:  ${distro_ver}
chroot_dir:  ${chroot_dir}
keepcache:   ${keepcache}
--------------------
EOS

#exit 0
[ -n "${batch}" ] && {
  yorn=y
} || {
  echo -n "OK? [y/n] "
  read yorn
  echo ${yorn}
}

case ${yorn} in
  n|N|no|NO) exit 1;;
esac

function do_cleanup() {
  printf "[DEBUG] Caught signal\n"
  umount -l ${chroot_dir}/proc
  [ -d ${chroot_dir} ] && rm -rf ${chroot_dir}
  [ -f ${repo} ] && rm -f ${repo}
  printf "[DEBUG] Cleaned up\n"
}
trap do_cleanup 1 2 3 15

[ -d ${chroot_dir} ] && { echo "${chroot_dir} already exists." >&2; exit 1; }
mkdir -p ${chroot_dir}

# /proc
mkdir ${chroot_dir}/proc
# mount -t proc none ${chroot_dir}/proc
mount --bind /proc ${chroot_dir}/proc

# /dev
mkdir ${chroot_dir}/dev
for i in console null tty1 tty2 tty3 tty4 zero; do
 /sbin/MAKEDEV -d ${chroot_dir}/dev -x $i
done


# yum
cat <<EOS > ${repo}
[main]
cachedir=/var/cache/yum
keepcache=${keepcache}
debuglevel=2
logfile=/var/log/yum.log
exactarch=1
obsoletes=1
gpgcheck=0
plugins=1
metadata_expire=1800
installonly_limit=2

# PUT YOUR REPOS HERE OR IN separate files named file.repo
# in /etc/yum.repos.d
[${distro_short}]
name=${distro_snake} ${distro_ver} - ${basearch}
failovermethod=priority
baseurl=${baseurl}
enabled=1
gpgcheck=1
gpgkey=${gpgkey}
EOS


# install packages
${yum_cmd} groupinstall Core
${yum_cmd} install \
             kernel dracut openssh openssh-clients openssh-server rpm yum curl dhclient \
             passwd grub \
             vim-minimal
${yum_cmd} erase selinux*




# /etc/fstab
cat <<EOS > ${chroot_dir}/etc/fstab
${root_dev}             /                       ext4    defaults        1 1
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0
EOS

# /etc/hosts
cat <<EOS > ${chroot_dir}/etc/hosts
127.0.0.1       localhost
EOS

# /etc/resolv.conf
cat <<EOS > ${chroot_dir}/etc/resolv.conf
nameserver 8.8.8.8
EOS

# /etc/sysconfig/network
cat <<EOS > ${chroot_dir}/etc/sysconfig/network
NETWORKING=yes
EOS

# /etc/sysconfig/network-scripts/ifcfg-eth0
cat <<EOS > ${chroot_dir}/etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes
EOS

# passwd
/usr/sbin/chroot ${chroot_dir} pwconv

# TimeZone
/bin/cp ${chroot_dir}/usr/share/zoneinfo/Japan ${chroot_dir}/etc/localtime

# diet
#${yum_cmd} erase kbd ed ustr checkpolicy

# needless services
/usr/sbin/chroot ${chroot_dir} /sbin/chkconfig --list |grep -v :on |\
 while read svc dummy; do
   /usr/sbin/chroot ${chroot_dir} /sbin/chkconfig --del ${svc}
 done

#
for grub_distro_name in redhat unknown; do
  grub_src_dir=${chroot_dir}/usr/share/grub/${basearch}-${grub_distro_name}
  [ -d ${grub_src_dir} ] || continue
  rsync -a ${grub_src_dir}/ ${chroot_dir}/boot/grub/
done

#
# clean-up
#
rm -f  ${chroot_dir}/boot/grub/splash.xpm.gz
find   ${chroot_dir}/var/log/ -type f | xargs rm
rm -rf ${chroot_dir}/tmp/*
rm -f  ${repo}

umount -l ${chroot_dir}/proc

printf "[INFO] Installed => %s\n" ${chroot_dir}
printf "[INFO] Complete!\n"
