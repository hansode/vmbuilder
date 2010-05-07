#!/bin/sh
#
export PATH=/bin:/usr/bin:/sbin:/usr/sbin

#
# vars
#
arch=i386
ver=8
dist=fedora
root_dev=/dev/xvda
console_dev=xvc0

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
    baseurl=http://srv2.ftp.ne.jp/Linux/packages/${dist_snake}/${ver}/os/${arch}/
    gpgkey="${baseurl}/RPM-GPG-KEY-${dist_snake}-${ver} ${baseurl}/RPM-GPG-KEY-beta"
    ;;
  fedora)
    dist_snake=Fedora
    ### fedora ###
    baseurl=http://srv2.ftp.ne.jp/Linux/packages/${dist}
    case ${ver} in
    [1-6])
      baseurl=${baseurl}/core/${ver}/i386/os/
      ;;
    [78])
      baseurl=${baseurl}/archive/releases/${ver}/${dist_snake}/${arch}/os/
      ;;
    1[12])
      baseurl=${baseurl}/releases/${ver}/${dist_snake}/${arch}/os/
      ;;
    esac 
    gpgkey="${baseurl}/RPM-GPG-KEY-${dist} ${baseurl}/RPM-GPG-KEY"
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
 /dev/MAKEDEV -d ${fakeroot}/dev -x $i
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
${yum_cmd} install kernel-xen mkinitrd openssh openssh-clients openssh-server rpm yum curl dhclient
${yum_cmd} erase selinux*




# /etc/fstab
cat <<EOS > ${fakeroot}/etc/fstab
${root_dev}               /                       ext3    defaults        1 1
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0
EOS

# /etc/hosts
cat <<EOS > ${fakeroot}/etc/hosts
127.0.0.1       localhost
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

# /etc/securetty
echo ${console_dev} > ${fakeroot}/etc/securetty

# /etc/inittab
cat <<EOS > ${fakeroot}/etc/inittab
#
# inittab       This file describes how the INIT process should set up
#               the system in a certain run-level.
#
# Author:       Miquel van Smoorenburg, <miquels@drinkel.nl.mugnet.org>
#               Modified for RHS Linux by Marc Ewing and Donnie Barnes
#

# Default runlevel. The runlevels used by RHS are:
#   0 - halt (Do NOT set initdefault to this)
#   1 - Single user mode
#   2 - Multiuser, without NFS (The same as 3, if you do not have networking)
#   3 - Full multiuser mode
#   4 - unused
#   5 - X11
#   6 - reboot (Do NOT set initdefault to this)
#
id:3:initdefault:

# System initialization.
si::sysinit:/etc/rc.d/rc.sysinit

l0:0:wait:/etc/rc.d/rc 0
l1:1:wait:/etc/rc.d/rc 1
l2:2:wait:/etc/rc.d/rc 2
l3:3:wait:/etc/rc.d/rc 3
l4:4:wait:/etc/rc.d/rc 4
l5:5:wait:/etc/rc.d/rc 5
l6:6:wait:/etc/rc.d/rc 6

# Trap CTRL-ALT-DELETE
ca::ctrlaltdel:/sbin/shutdown -t3 -r now

# When our UPS tells us power has failed, assume we have a few minutes
# of power left.  Schedule a shutdown for 2 minutes from now.
# This does, of course, assume you have powerd installed and your
# UPS connected and working correctly.
pf::powerfail:/sbin/shutdown -f -h +2 "Power Failure; System Shutting Down"

# If power was restored before the shutdown kicked in, cancel it.
pr:12345:powerokwait:/sbin/shutdown -c "Power Restored; Shutdown Cancelled"

# Run gettys in standard runlevels
co:2345:respawn:/sbin/agetty ${console_dev} 9600 vt100-nav

# Run xdm in runlevel 5
EOS

# /etc/modprobe.conf
cat <<EOS > ${fakeroot}/etc/modprobe.conf
alias scsi_hostadapter xenblk
alias eth0 xennet
EOS

# passwd
/usr/sbin/chroot ${fakeroot} pwconv
/usr/sbin/chroot ${fakeroot} passwd -d root

# service
/usr/sbin/chroot ${fakeroot} chkconfig --del kudzu

# TimeZone
/bin/cp ${fakeroot}/usr/share/zoneinfo/Japan ${fakeroot}/etc/localtime

# diet
${yum_cmd} erase kudzu wireless-tools kbd slang audit-libs-python ed ustr setserial checkpolicy libselinux-python



# rebuild initrd for domU
ls -1 ${fakeroot}/lib/modules/ | tail -1 | while read i; do
  modver=$(basename ${i})
  [ -f  ${fakeroot}/boot/initrd-${modver}.img ] && {
    /bin/rm ${fakeroot}/boot/initrd-${modver}.img
    /usr/sbin/chroot ${fakeroot} \
      /sbin/mkinitrd \
        --preload=ext3 \
        --preload=xenblk \
        /boot/initrd-${modver}.img ${modver}

# /boot/grub/grub.conf
cat <<EOS > ${fakeroot}/boot/grub/grub.conf
default=0
timeout=3
hiddenmenu
title ${dist_snake} (${modver})
        root (hd0,0)
        kernel /boot/vmlinuz-${modver} ro root=${root_dev} console=${console_dev}
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
# clean-up
#
rm -f  ${fakeroot}/boot/grub/splash.xpm.gz
find   ${fakeroot}/var/log/ -type f | xargs rm
rm -rf ${fakeroot}/tmp/*

umount ${fakeroot}/proc

exit 0
