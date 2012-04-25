#!/bin/bash
#
# OPTIONS
#        --distro_arch=x86_64
#        --distro_name=[centos | sl]
#        --distro_ver=[6 | 6.0 | 6.2 | ... ]
#        --batch=1
#        --chroot_dir=/path/to/rootfs
#        --debug=1
#
export PATH=/bin:/usr/bin:/sbin:/usr/sbin

#
set -e

args=
while [ $# -gt 0 ]; do
  arg="$1"
  case "${arg}" in
    --*=*)
      key=${arg%%=*}; key=${key##--}
      value=${arg##--*=}
      eval "${key}=\"${value}\""
      ;;
    *)
      args="${args} ${arg}"
      ;;
  esac
  shift
done

debug=${debug:-}
[ -z ${debug} ] || set -x

#
# vars
#
distro_arch=${distro_arch:-x86_64}
distro_ver=${distro_ver:-6}
distro_name=${distro_name:-centos}
root_dev=${root_dev:-/dev/sda1}

abs_path=$(cd $(dirname $0) && pwd)
chroot_dir=${chroot_dir:-${abs_path}/${distro_short}-${distro_ver}_${distro_arch}}

# check
[[ $UID -ne 0 ]] && {
  echo "ERROR: Run as root" >/dev/stderr
  exit 1
}

which yum >/dev/null 2>&1 || {
  echo "[error] command not found: 'yum'" >&2
  exit 1;
}

# validate
case ${distro_arch} in
  i386|x86_64) ;;
  *) distro_arch=i386 ;;
esac

case ${distro_name} in
  centos)
    distro_short=centos
    distro_snake=CentOS
    baseurl=http://ftp.riken.go.jp/pub/Linux/centos/${distro_ver}/os/${distro_arch}
    case ${distro_ver} in
    6|6.*)
      gpgkey="${baseurl}/RPM-GPG-KEY-${distro_snake}-6"
      ;;
    esac
    ;;
  sl|scientific|scientificlinux)
    distro_short=sl
    distro_snake="Scientific Linux"
    baseurl=http://ftp.riken.go.jp/pub/Linux/scientific/${distro_ver}/${distro_arch}/os
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


# dump vars
cat <<EOS
--------------------
distro_arch: ${distro_arch}
distro_name: ${distro_name} ${distro_snake}
distro_ver:  ${distro_ver}
chroot_dir:  ${chroot_dir}
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



#
#
#
repo=${abs_path}/yum-${distro_short}-${distro_ver}.repo
yum_cmd="
yum \
 -c ${repo} \
 --disablerepo="\*" \
 --enablerepo="${distro_short}" \
 --installroot=${chroot_dir} \
 -y
"


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
keepcache=0
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
name=${distro_snake} ${distro_ver} - ${distro_arch}
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
#UUID=${rootdev_uuid} /                       ext4    defaults        1 1
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
## ${yum_cmd} erase kbd slang audit-libs-python ed ustr setserial checkpolicy

# needless services
/usr/sbin/chroot ${chroot_dir} /sbin/chkconfig --list |grep -v :on |\
 while read svc dummy; do
   /usr/sbin/chroot ${chroot_dir} /sbin/chkconfig --del ${svc}
 done

#
for grub_distro_name in redhat unknown; do
  grub_src_dir=${chroot_dir}/usr/share/grub/${distro_arch}-${grub_distro_name}
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

umount ${chroot_dir}/proc

exit 0
