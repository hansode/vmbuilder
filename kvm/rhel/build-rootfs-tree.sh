#!/bin/sh
#
export PATH=/bin:/usr/bin:/sbin:/usr/sbin

#
# vars
#
arch=x86_64
ver=6
dist=centos
root_dev=/dev/sda1

# check
which yum >/dev/null 2>&1 || {
  echo "[error] command not found: 'yum'" >&2
  exit 1;
}

# main
for arg in $*; do
case $arg in
  --arch=*) arch=${arg##--arch=} ;;
  --dist=*) dist=${arg##--dist=} ;;
  --ver=*)  ver=${arg##--ver=} ;;
esac
done

# validate
case ${arch} in
  i386|x86_64) ;;
  *) arch=i386 ;;
esac

case ${dist} in
  centos)
    dist_snake=CentOS
    ### centos ###
    baseurl=http://srv2.ftp.ne.jp/Linux/packages/${dist_snake}/${ver}/os/${arch}
    case ${ver} in
    6|6.*)
      gpgkey="${baseurl}/RPM-GPG-KEY-${dist_snake}-6 ${baseurl}/RPM-GPG-KEY-beta"
      ;;
    esac
    ;;
  *)
    echo "no mutch" >&2
    exit 1;
esac


# dump vars
cat <<EOS
--------------------
arch: ${arch}
dist: ${dist} ${dist_snake}
ver:  ${ver}
--------------------
EOS

#exit 0
echo -n "OK? [y/n] "
read yorn
echo ${yorn}

case ${yorn} in
  n|N|no|NO) exit 1;;
esac



#
#
#
pwd=$(cd $(dirname $0) && pwd)
fakeroot=${pwd}/${dist}-${ver}_${arch}
repo=${pwd}/yum-${dist}-${ver}.repo
yum_cmd="
yum \
 -c ${repo} \
 --disablerepo="\*" \
 --enablerepo="${dist}" \
 --installroot=${fakeroot} \
 -y
"


[ -d ${fakeroot} ] && { echo "${fakeroot} already exists." >&2; exit 1; }
mkdir -p ${fakeroot}

# /proc
mkdir ${fakeroot}/proc
# mount -t proc none ${fakeroot}/proc
mount --bind /proc ${fakeroot}/proc

# /dev
mkdir ${fakeroot}/dev
for i in console null tty1 tty2 tty3 tty4 zero; do
 /sbin/MAKEDEV -d ${fakeroot}/dev -x $i
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
[${dist}]
name=${dist} ${ver} - ${arch}
failovermethod=priority
baseurl=${baseurl}
enabled=1
gpgcheck=1
gpgkey=${gpgkey}
EOS


# install packages
${yum_cmd} groupinstall Core
${yum_cmd} install kernel mkinitrd openssh openssh-clients openssh-server rpm yum curl dhclient
${yum_cmd} install passwd grub
${yum_cmd} erase selinux*




# /etc/fstab
cat <<EOS > ${fakeroot}/etc/fstab
#UUID=${rootdev_uuid} /                       ext4    defaults        1 1
${root_dev}             /                       ext4    defaults        1 1
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0
EOS

# /etc/hosts
cat <<EOS > ${fakeroot}/etc/hosts
127.0.0.1       localhost
EOS

# /etc/resolv.conf
cat <<EOS > ${fakeroot}/etc/resolv.conf
nameserver 8.8.8.8
EOS

# /etc/sysconfig/network
cat <<EOS > ${fakeroot}/etc/sysconfig/network
NETWORKING=yes
EOS

# /etc/sysconfig/network-scripts/ifcfg-eth0
cat <<EOS > ${fakeroot}/etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes
EOS

# /etc/inittab
cat <<EOS > ${fakeroot}/etc/inittab
#
# ADDING OTHER CONFIGURATION HERE WILL HAVE NO EFFECT ON YOUR SYSTEM.
#
# System initialization is started by /etc/init/rcS.conf
#
# Individual runlevels are started by /etc/init/rc.conf
#
# Ctrl-Alt-Delete is handled by /etc/init/control-alt-delete.conf
#
# Terminal gettys are handled by /etc/init/tty.conf and /etc/init/serial.conf,
# with configuration in /etc/sysconfig/init.
#
# For information on how to write upstart event handlers, or how
# upstart works, see init(5), init(8), and initctl(8).
#
# Default runlevel. The runlevels used are:
#   0 - halt (Do NOT set initdefault to this)
#   1 - Single user mode
#   2 - Multiuser, without NFS (The same as 3, if you do not have networking)
#   3 - Full multiuser mode
#   4 - unused
#   5 - X11
#   6 - reboot (Do NOT set initdefault to this)
#
id:3:initdefault:
EOS

# /etc/modprobe.conf
#cat <<EOS > ${fakeroot}/etc/modprobe.conf
#alias scsi_hostadapter xenblk
#alias eth0 xennet
#EOS

# passwd
/usr/sbin/chroot ${fakeroot} pwconv
#/usr/sbin/chroot ${fakeroot} passwd -d root

# TimeZone
/bin/cp ${fakeroot}/usr/share/zoneinfo/Japan ${fakeroot}/etc/localtime

# diet
## ${yum_cmd} erase kbd slang audit-libs-python ed ustr setserial checkpolicy



# rebuild initrd for domU
ls -1 ${fakeroot}/lib/modules/ | tail -1 | while read i; do
  modver=$(basename ${i})
  [ -f  ${fakeroot}/boot/initrd-${modver}.img ] && {
    /bin/rm ${fakeroot}/boot/initrd-${modver}.img
    /usr/sbin/chroot ${fakeroot} \
      /sbin/mkinitrd \
        --preload=ext4 \
        /boot/initrd-${modver}.img ${modver}

# /boot/grub/grub.conf
cat <<EOS > ${fakeroot}/boot/grub/grub.conf
default=0
timeout=3
hiddenmenu
title ${dist_snake} (${modver})
        root (hd0,0)
        kernel /boot/vmlinuz-${modver} ro root=${root_dev}
        initrd /boot/initrd-${modver}.img
EOS
#

  }
done

# needless services
/usr/sbin/chroot ${fakeroot} /sbin/chkconfig --list |grep -v :on |\
 while read svc dummy; do
   /usr/sbin/chroot ${fakeroot} /sbin/chkconfig --del ${svc}
 done

#
rsync -a ${fakeroot}/usr/share/grub/${arch}-redhat/ ${fakeroot}/boot/grub/


#
# clean-up
#
rm -f  ${fakeroot}/boot/grub/splash.xpm.gz
find   ${fakeroot}/var/log/ -type f | xargs rm
rm -rf ${fakeroot}/tmp/*

umount ${fakeroot}/proc

exit 0
