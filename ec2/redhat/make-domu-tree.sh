#!/bin/sh
#
export PATH=/bin:/usr/bin:/sbin:/usr/sbin

#
# vars
#
arch=i386
ver=8
dist=fedora
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
  x86_64)
    module_arch=x86_64
    ;;
  *) arch=i386
    module_arch=i686
    ;;
esac

# linux module
module_path=http://s3.amazonaws.com/ec2-downloads
module_file=ec2-modules-2.6.21.7-2.ec2.v1.2.fc8xen-${module_arch}.tgz
module_uri=${module_path}/${module_file}
kernel_ver=2.6.21.7-2.fc8xen-ec2-v1.0

case ${dist} in
  centos)
    dist_snake=CentOS
    ### centos ###
    baseurl=http://srv2.ftp.ne.jp/Linux/packages/${dist_snake}/${ver}/os/${arch}
    case ${ver} in
    3|3.*)
      gpgkey="${baseurl}/RPM-GPG-KEY-${dist_snake}-3 ${baseurl}/RPM-GPG-KEY"
      ;;
    4|4.*)
      gpgkey="${baseurl}/RPM-GPG-KEY-${dist}4 ${baseurl}/RPM-GPG-KEY"
      ;;
    5|5.*)
      gpgkey="${baseurl}/RPM-GPG-KEY-${dist_snake}-5 ${baseurl}/RPM-GPG-KEY-beta"
      ;;
    esac
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
${yum_cmd} install openssh openssh-clients openssh-server rpm yum curl dhclient
${yum_cmd} erase selinux*




# /etc/fstab
cat <<EOS > ${fakeroot}/etc/fstab
/dev/sda1               /                       ext3    defaults 1 1
/dev/sda2               /mnt                    ext3    defaults 0 0
/dev/sda3               swap                    swap    defaults 0 0
none                    /dev/pts                devpts  gid=5,mode=620 0 0
none                    /dev/shm                tmpfs   defaults 0 0
none                    /proc                   proc    defaults 0 0
none                    /sys                    sysfs   defaults 0 0
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
TYPE=Ethernet
USERCTL=yes
PEERDNS=yes
IPV6INIT=no
EOS

# /etc/securetty
echo ${console_dev} > ${fakeroot}/etc/securetty

# /etc/inittab
cat <<'EOS' > ${fakeroot}/usr/local/sbin/get-credentials.sh
#!/bin/bash
#
# via http://developer.amazonwebservices.com/connect/message.jspa?messageID=76866
#

# Retreive the credentials from relevant sources.

# Fetch any credentials presented at launch time and add them to
# root's public keys

PUB_KEY_URI=http://169.254.169.254/1.0/meta-data/public-keys/0/openssh-key
PUB_KEY_FROM_HTTP=/tmp/openssh_id.pub
PUB_KEY_FROM_EPHEMERAL=/mnt/openssh_id.pub
ROOT_AUTHORIZED_KEYS=/root/.ssh/authorized_keys



# We need somewhere to put the keys.
if [ ! -d /root/.ssh ] ; then
        mkdir -p /root/.ssh
        chmod 700 /root/.ssh
fi

# Fetch credentials...

# First try http
curl --retry 3 --retry-delay 0 --silent --fail -o $PUB_KEY_FROM_HTTP $PUB_KEY_URI
if [ $? -eq 0 -a -e $PUB_KEY_FROM_HTTP ] ; then
    if ! grep -q -f $PUB_KEY_FROM_HTTP $ROOT_AUTHORIZED_KEYS
    then
            cat $PUB_KEY_FROM_HTTP >> $ROOT_AUTHORIZED_KEYS
            echo "New key added to authrozied keys file from parameters"|logger -t "ec2"
    fi
    chmod 600 $ROOT_AUTHORIZED_KEYS
    rm -f $PUB_KEY_FROM_HTTP

elif [ -e $PUB_KEY_FROM_EPHEMERAL ] ; then
    # Try back to ephemeral store if http failed.
    # NOTE: This usage is deprecated and will be removed in the future
    if ! grep -q -f $PUB_KEY_FROM_EPHEMERAL $ROOT_AUTHORIZED_KEYS
    then
            cat $PUB_KEY_FROM_EPHEMERAL >> $ROOT_AUTHORIZED_KEYS
            echo "New key added to authrozied keys file from ephemeral store"|logger -t "ec2"

    fi
    chmod 600 $ROOT_AUTHORIZED_KEYS
    chmod 600 $PUB_KEY_FROM_EPHEMERAL

fi

if [ -e /mnt/openssh_id.pub ] ; then
        if ! grep -q -f /mnt/openssh_id.pub /root/.ssh/authorized_keys
        then
                cat /mnt/openssh_id.pub >> /root/.ssh/authorized_keys
                echo "New key added to authrozied keys file from ephemeral store"|logger -t "ec2"

        fi
        chmod 600 /root/.ssh/authorized_keys
fi
EOS

chmod +x ${fakeroot}/usr/local/sbin/get-credentials.sh

# /etc/rc.d/rc.local
cat <<'EOS' >> ${fakeroot}/etc/rc.d/rc.local
# Get your chosen keypair credentials
/usr/local/sbin/get-credentials.sh 
EOS


# disable selinux
mv -i ${fakeroot}/etc/selinux/config ${fakeroot}/etc/selinux/config.0
cat <<'EOS' > ${fakeroot}/etc/selinux/config
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#       enforcing - SELinux security policy is enforced.
#       permissive - SELinux prints warnings instead of enforcing.
#       disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of these two values:
#       targeted - Targeted processes are protected,
#       mls - Multi Level Security protection.
SELINUXTYPE=targeted
# SETLOCALDEFS= Check local definition changes
SETLOCALDEFS=0
EOS


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

echo
echo
echo


# needless services
/usr/sbin/chroot ${fakeroot} /sbin/chkconfig --list |grep -v :on |\
 while read svc dummy; do
   /usr/sbin/chroot ${fakeroot} /sbin/chkconfig --del ${svc}
 done

# linux module
[ -f ${module_file} ] || wget ${module_uri}
echo "Extracting ${module_file} ..."
tar zxpf ${module_file} -C ${fakeroot}/

# rebuild initrd for domU
ls -1 ${fakeroot}/lib/modules/ | tail -1 | while read i; do
  modver=$(basename ${i})
  (cd ${fakeroot}/lib/modules/ && ln -s ${modver} ${kernel_ver})
done

# /etc/ld.so.conf.d/
confs="
 kernelcap-2.6.21-2950.fc8.conf
 kernelcap-2.6.21.7-5.fc8.conf
 kernelcap-2.6.21.7-2.fc8.conf
"
for i in ${confs}; do
  echo "Generating ${fakeroot}/etc/ld.so.conf.d/$i ..."
  echo 'hwcap 0 nosegneg' > ${fakeroot}/etc/ld.so.conf.d/$i
done

# kernel module
echo depmod -a ${kernel_ver}
chroot ${fakeroot} depmod -a ${kernel_ver}
echo ldconfig
chroot ${fakeroot} ldconfig

# /etc/ssh/sshd_config
echo Reconfiguring /etc/ssh/sshd_config ...
egrep -q '^PasswordAuthentication' ${fakeroot}/etc/ssh/sshd_config && {
  perl -pi -e 's,^PasswordAuthentication.*,PasswordAuthentication no,' ${fakeroot}/etc/ssh/sshd_config
} || {
  echo 'PasswordAuthentication no' >> ${fakeroot}/etc/ssh/sshd_config
}

# /etc/motd
echo Generating /etc/motd ...
cat <<EOS | tee ${fakeroot}/etc/motd
${dist_snake}-${ver} (${arch})

 * http://github.com/hansode/vmbuilder/

EOS

echo


#
# clean-up
#
rm -f  ${fakeroot}/boot/grub/splash.xpm.gz
find   ${fakeroot}/var/log/ -type f | xargs rm
rm -rf ${fakeroot}/tmp/*

umount ${fakeroot}/proc

echo done.
exit 0
