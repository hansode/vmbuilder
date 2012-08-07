#!/bin/bash
#
# <based on vmbuilder>
#
# NAME
#        vmbuilder - builds virtual machines from the command line
#
# SYNOPSIS
#        vmbuilder <hypervisor> <distro> [OPTIONS]...
#
#        <hypervisor>  Hypervisor image format. Valid options: xen kvm vmw6 vmserver
#
#        <distro>      Distribution. Valid options: ubuntu
#
# OPTIONS
#
#    Guest partitioning options
#
#        The following three options are not used if --part is specified:
#
#               --rootsize SIZE
#                      Size (in MB) of the root filesystem [default: 4096].  Discarded when --part is used.
#
#               --optsize SIZE
#                      Size (in MB) of the /opt filesystem. If not set, no /opt filesystem will be added. Discarded when --part is used.
#
#               --swapsize SIZE
#                      Size (in MB) of the swap partition [default: 1024]. Discarded when --part is used.
#
#   Network related options:
#       --domain DOMAIN
#              Set DOMAIN as the domain name of the guest. Default: The domain of the machine running this script.
#
#       --ip ADDRESS
#              IP address in dotted form [default: dhcp]
#
#       Options below are discarded if --ip is not specified
#              --mask VALUE IP mask in dotted form [default: based on ip setting].
#
#              --net ADDRESS
#                     IP net address in dotted form [default: based on ip setting].
#
#              --bcast VALUE
#                     IP broadcast in dotted form [default: based on ip setting].
#
#              --gw ADDRESS
#                     Gateway (router) address in dotted form [default: based on ip setting (first valid address in the network)].
#
#              --dns ADDRESS
#                     DNS address in dotted form [default: based on ip setting (first valid address in the network)]
#
#    Post install actions:
#        --copy FILE
#               Read 'source dest' lines from FILE, copying source files from host to dest in the guest's file system.
#
#        --execscript SCRIPT, --exec SCRIPT
#               Run SCRIPT after distro installation finishes. Script will be called with the guest's chroot as first argument, so you can use chroot $1 <cmd> to  run  code  in
#               the virtual machine.
#
#
# <based ontune2fs>
#
#       -c max-mount-counts
#              Adjust the number of mounts after which the filesystem will be checked by e2fsck(8).  If max-mount-counts is 0 or  -1,  the  number  of  times  the
#              filesystem is mounted will be disregarded by e2fsck(8) and the kernel.
#
#              Staggering  the  mount-counts  at  which filesystems are forcibly checked will avoid all filesystems being checked at one time when using journaled
#              filesystems.
#
#              You should strongly consider the consequences of disabling mount-count-dependent checking entirely.  Bad disk drives, cables,  memory,  and  kernel
#              bugs  could  all  corrupt  a  filesystem  without  marking  the filesystem dirty or in error.  If you are using journaling on your filesystem, your
#              filesystem will never be marked dirty, so it will not normally be checked.  A filesystem error detected by the kernel will still force an  fsck  on
#              the next reboot, but it may already be too late to prevent data loss at that point.
#
#              See also the -i option for time-dependent checking.
#
#       -i  interval-between-checks[d|m|w]
#              Adjust the maximal time between two filesystem checks.  No suffix or d will interpret the number interval-between-checks as days, m as months,  and
#              w as weeks.  A value of zero will disable the time-dependent checking.
#
#              It  is  strongly  recommended  that  either  -c (mount-count-dependent) or -i (time-dependent) checking be enabled to force periodic full e2fsck(8)
#              checking of the filesystem.  Failure to do so may lead to filesystem corruption (due to bad disks, cables, memory, or kernel bugs) going unnoticed,
#              ultimately resulting in data loss or corruption.
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
debug=${debug:-}
[ -z "${debug}" ] || set -x
abs_path=$(cd $(dirname $0) && pwd)

#
distro_name=${distro_name:-centos}
distro_ver=${distro_ver:-6}

distro_arch=${distro_arch:-$(arch)}
case ${distro_arch} in
i*86)   basearch=i386; distro_arch=i686;;
x86_64) basearch=${distro_arch};;
esac

distro=${distro_name}-${distro_ver}_${distro_arch}
distro_dir=${distro_dir:-`pwd`/${distro}}

keepcache=${keepcache:-0}
# keepcache should be [ 0 | 1 ]
case ${keepcache} in
[01]) ;;
*)    keepcache=0 ;;
esac

[ -d "${distro_dir}" ] || {
  printf "[INFO] Building OS tree: %s\n" ${distro_dir}
  ${abs_path}/build-rootfs-tree.sh --distro-name=${distro_name} --distro-ver=${distro_ver} --distro-arch=${distro_arch} --chroot-dir=${distro_dir} --keepcache=${keepcache} --batch=1 --debug=1
}

# * tune2fs
# > This filesystem will be automatically checked every 37 mounts or
# > 180 days, whichever comes first.  Use tune2fs -c or -i to override.
max_mount_count=${max_mount_count:-37}
interval_between_check=${interval_between_check:-180}


# * /usr/share/pyshared/VMBuilder/contrib/cli.py

#
# OptionGroup('Disk')
# -------------------
#
# + ('--rootsize', metavar='SIZE', default=4096, help='Size (in MB) of the root filesystem [default: %default]')
# + ('--optsize', metavar='SIZE', default=0, help='Size (in MB) of the /opt filesystem. If not set, no /opt filesystem will be added.')
# + ('--swapsize', metavar='SIZE', default=1024, help='Size (in MB) of the swap partition [default: %default]')
# + ('--raw', metavar='PATH', type='str', help="Specify a file (or block device) to as first disk image.")
#
rootsize=${rootsize:-4096}
optsize=${optsize:-0}
swapsize=${swapsize:-1024}
execscript=${execscript:-}
raw=${raw:-./${distro}.raw}

#domain=${domain:-}
ip=${ip:-}
mask=${mask:-}
net=${net:-}
bcast=${bcast:-}
gw=${gw:-}
dns=${dns:-}
hostname=${hostname:-}

# local params
disk_filename=${raw}
size=$((${rootsize} + ${optsize} + ${swapsize}))

# * /usr/share/pyshared/VMBuilder/disk.py
# rhel)
# qemu_img_path=qemu-img
# ubuntu|debian)
# qemu_img_path=kvm-img


# def create(self):
printf "[INFO] Creating disk image: \"%s\" of size: %dMB\n" ${disk_filename} ${size}
#${qemu_img_path} create -f raw ${disk_filename} ${size}M
#dd if=/dev/zero of=${disk_filename} bs=1M count=${size}
truncate -s ${size}M ${disk_filename}

# def partition(self)
printf "[INFO] Adding partition table to disk image: %s\n" ${disk_filename}
parted --script    ${disk_filename} mklabel msdos

offset=0
# root
printf "[INFO] Adding type %s partition to disk image: %s\n" ext2 ${disk_filename}
parted --script -- ${disk_filename} mkpart  primary ext2 ${offset} $((${rootsize} - 1))
offset=$((${offset} + ${rootsize}))
# swap
printf "[INFO] Adding type %s partition to disk image: %s\n" swap ${disk_filename}
parted --script -- ${disk_filename} mkpart  primary 'linux-swap(new)' ${offset} $((${offset} + ${swapsize} - 1))
offset=$((${offset} + ${swapsize}))
# opt
[ ${optsize} -gt 0 ] && {
  printf "[INFO] Adding type %s partition to disk image: %s\n" ext2 ${disk_filename}
  parted --script -- ${disk_filename} mkpart  primary ext2 ${offset} $((${offset} + ${optsize} - 1))
}
unset offset

# def map_partitions(self):
#        mapdevs = []
#        for line in parts:
#            mapdevs.append(line.split(' ')[2])
printf "[INFO] Creating loop devices corresponding to the created partitions\n"
which kpartx >/dev/null || exit 1
mapdevs=$(
 kpartx -va ${disk_filename} \
  | egrep -v "^(gpt|dos):" \
  | egrep -w add \
  | while read line; do
      echo ${line} | awk '{print $3}'
    done
)
#        for (part, mapdev) in zip(self.partitions, mapdevs):
#            part.set_filename('/dev/mapper/%s' % mapdev)
part_filenames=$(
  for mapdev in ${mapdevs}; do
    echo /dev/mapper/${mapdev}
  done
)

#    def mkfs(self):
#        if not self.filename:
#            raise VMBuilderException('We can\'t mkfs if filename is not set. Did you forget to call .create()?')
#        if not self.dummy:
#            cmd = self.mkfs_fstype() + [self.filename]
#            run_cmd(*cmd)
#            # Let udev have a chance to extract the UUID for us
#            run_cmd('udevadm', 'settle')
#            if os.path.exists("/sbin/vol_id"):
#                self.uuid = run_cmd('vol_id', '--uuid', self.filename).rstrip()
#            elif os.path.exists("/sbin/blkid"):
#                self.uuid = run_cmd('blkid', '-c', '/dev/null', '-sUUID', '-ovalue', self.filename).rstrip()

getid_path=
[ -x /sbin/vol_id ] && getid_path=/sbin/vol_id || :
[ -x /sbin/blkid  ] && getid_path=/sbin/blkid  || :

uuids=
for part_filename in ${part_filenames}; do
  case ${part_filename} in
  *p1|*p3)
    mkfs.ext4 -F ${part_filename}

    # > This filesystem will be automatically checked every 37 mounts or
    # > 180 days, whichever comes first.  Use tune2fs -c or -i to override.
    [ ! "${max_mount_count}" -eq 37 -o ! "${interval_between_check}" -eq 180 ] && {
      printf "[INFO] Setting maximal mount count: %s\n" ${max_mount_count}
      printf "[INFO] Setting interval between check(s): %s\n" ${interval_between_check}
      tune2fs -c ${max_mount_count} -i ${interval_between_check} ${part_filename}
    }
    ;;
  *p2)
    mkswap ${part_filename}
    ;;
  *)
    ;;
  esac
  udevadm settle
  case ${getid_path} in
  /sbin/vol_id)
    uuid=$(${getid_path} --uuid ${part_filename})
    ;;
  /sbin/blkid)
    uuid=$(${getid_path} -c /dev/null -sUUID -ovalue ${part_filename})
    ;;
  esac

  uuids="${uuids} ${uuid}"
done


#    def mount(self, rootmnt):
#        if (self.type != TYPE_SWAP) and not self.dummy:
#            logging.debug('Mounting %s', self.mntpnt)
#            self.mntpath = '%s%s' % (rootmnt, self.mntpnt)
#            if not os.path.exists(self.mntpath):
#                os.makedirs(self.mntpath)
#            run_cmd('mount', '-o', 'loop', self.filename, self.mntpath)
#            self.vm.add_clean_cb(self.umount)

mntpnt=/tmp/tmp$(date +%s)
[ -d "${mntpnt}" ] && { exit 1; } || mkdir -p ${mntpnt}

# setup to unmount and clean up
trap '
set +e
for tmpmnt in ${chroot_dir}/${new_filename} ${mntpnt}; do
  while grep -q ${tmpmnt} /proc/mounts; do
    umount -l ${tmpmnt}
  done
done
' 0 2 3 15

for part_filename in ${part_filenames}; do
  case ${part_filename} in
  *p1)
    printf "[DEBUG] Mounting %s\n" ${mntpnt}
    mount -o loop ${part_filename} ${mntpnt}
    ;;
  esac
done

#    def install_os(self):
#        self.nics = [self.NIC()]
#        self.call_hooks('preflight_check')
#        self.call_hooks('configure_networking', self.nics)
#        self.call_hooks('configure_mounting', self.disks, self.filesystems)
#
#        self.chroot_dir = tmpdir()
#        self.call_hooks('mount_partitions', self.chroot_dir)
#        run_cmd('rsync', '-aHA', '%s/' % self.distro.chroot_dir, self.chroot_dir)
#distro=centos-6_x86_64
#distro_dir=./${distro}

[ -d "${distro_dir}" ] || { echo "no such directory: ${distro_dir}" >&2; exit 1; }

printf "[DEBUG] Installing OS to %s\n" ${mntpnt}
rsync -aHA ${distro_dir}/ ${mntpnt}
sync

printf "[INFO] Setting /etc/yum.conf: keepcache=%s\n" ${keepcache}
sed -i s,^keepcache=.*,keepcache=${keepcache}, ${mntpnt}/etc/yum.conf

#        if self.needs_bootloader:
#            self.call_hooks('install_bootloader', self.chroot_dir, self.disks)
#        self.call_hooks('install_kernel', self.chroot_dir)
#        self.call_hooks('unmount_partitions')
#        os.rmdir(self.chroot_dir)



# * /usr/share/pyshared/VMBuilder/plugins/ubuntu/distro.py
#    def install_bootloader(self, chroot_dir, disks):
chroot_dir=${mntpnt}

#        root_dev = VMBuilder.disk.bootpart(disks).get_grub_id()

#
#        tmpdir = '/tmp/vmbuilder-grub'
#        os.makedirs('%s%s' % (chroot_dir, tmpdir))
tmpdir=/tmp/vmbuilder-grub
mkdir -p ${chroot_dir}/${tmpdir}

#        self.context.add_clean_cb(self.install_bootloader_cleanup)
#        devmapfile = os.path.join(tmpdir, 'device.map')
#        devmap = open('%s%s' % (chroot_dir, devmapfile), 'w')
devmapfile=${tmpdir}/device.map
touch ${chroot_dir}/${devmapfile}

#        for (disk, id) in zip(disks, range(len(disks))):
grub_id=0

#            new_filename = os.path.join(tmpdir, os.path.basename(disk.filename))
#            open('%s%s' % (chroot_dir, new_filename), 'w').close()
#            run_cmd('mount', '--bind', disk.filename, '%s%s' % (chroot_dir, new_filename))
new_filename=${tmpdir}/$(basename ${disk_filename})
touch ${chroot_dir}/${new_filename}
mount --bind ${disk_filename} ${chroot_dir}/${new_filename}

#            st = os.stat(disk.filename)
#            if stat.S_ISBLK(st.st_mode):
#                for (part, part_id) in zip(disk.partitions, range(len(disk.partitions))):
#                    part_mountpnt = '%s%s%d' % (chroot_dir, new_filename, part_id+1)
#                    open(part_mountpnt, 'w').close()
#                    run_cmd('mount', '--bind', part.filename, part_mountpnt)
#            devmap.write("(hd%d) %s\n" % (id, new_filename))
printf "(hd%d) %s\n" ${grub_id} ${new_filename} >> ${chroot_dir}/${devmapfile}

#        devmap.close()
#        run_cmd('cat', '%s%s' % (chroot_dir, devmapfile))
cat ${chroot_dir}/${devmapfile}

#        self.suite.install_grub(chroot_dir)
#        self.run_in_target('grub', '--device-map=%s' % devmapfile, '--batch',  stdin='''root %s
#setup (hd0)
#EOT''' % root_dev)

cat <<_EOS_ | chroot ${chroot_dir} grub --device-map=${devmapfile} --batch
root (hd${grub_id},0)
setup (hd0)
quit
_EOS_

#
rootdev_uuid=$(echo ${uuids} | awk '{print $1}')
swapdev_uuid=$(echo ${uuids} | awk '{print $2}')
optdev_uuid=$(echo ${uuids} | awk '{print $3}')

# /boot/grub/grub.conf
printf "[INFO] Generating /boot/grub/grub.conf.\n"
cat <<_EOS_ > ${chroot_dir}/boot/grub/grub.conf
default=0
timeout=5
splashimage=(hd${grub_id},0)/boot/grub/splash.xpm.gz
hiddenmenu
title ${distro} ($(cd ${chroot_dir}/boot && ls vmlinuz-* | tail -1 | sed 's,^vmlinuz-,,'))
        root (hd${grub_id},0)
        kernel /boot/$(cd ${chroot_dir}/boot && ls vmlinuz-* | tail -1) ro root=UUID=${rootdev_uuid} rd_NO_LUKS rd_NO_LVM LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM
        initrd /boot/$(cd ${chroot_dir}/boot && ls initramfs-*| tail -1)
_EOS_
cat ${chroot_dir}/boot/grub/grub.conf
chroot ${chroot_dir} ln -s /boot/grub/grub.conf /boot/grub/menu.lst

# /etc/fstab
printf "[INFO] Overwriting /etc/fstab.\n"
cat <<_EOS_ > ${chroot_dir}/etc/fstab
UUID=${rootdev_uuid} /                       ext4    defaults        1 1
UUID=${swapdev_uuid} swap                    swap    defaults        0 0
$([ ${optsize} -gt 0 ] && { cat <<_OPTDEV_
UUID=${optdev_uuid} /opt                    ext4    defaults        1 1
_OPTDEV_
})
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0
_EOS_
cat ${chroot_dir}/etc/fstab

DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes

# /etc/sysconfig/network-scripts/ifcfg-eth0
[ -z "${ip}" ] || {
  printf "[INFO] Unsetting /etc/sysconfig/network-scripts/ifcfg-eth0.\n"
  cat <<_EOS_ > ${chroot_dir}/etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=static
ONBOOT=yes

IPADDR=${ip}
$([ -z "${net}"   ] || echo "NETMASK=${net}")
$([ -z "${bcast}" ] || echo "BROADCAST=${bcast}")
$([ -z "${gw}"    ] || echo "GATEWAY=${gw}")
_EOS_
  cat ${chroot_dir}/etc/sysconfig/network-scripts/ifcfg-eth0
}

# /etc/resolv.conf
[ -z "${dns}" ] || {
  printf "[INFO] Unsetting /etc/resolv.conf.\n"
  cat <<_EOS_ > ${chroot_dir}/etc/resolv.conf
nameserver ${dns}
_EOS_
  cat ${chroot_dir}/etc/resolv.conf
}

# hostname
[ -z "${hostname}" ] || {
  printf "[INFO] Setting hostname: %s\n" ${hostname}
  egrep ^HOSTNAME= ${chroot_dir}/etc/sysconfig/network -q && {
    sed -i "s,^HOSTNAME=.*,HOSTNAME=${hostname}," ${chroot_dir}/etc/sysconfig/network
  } || {
    echo HOSTNAME=${hostname} >> ${chroot_dir}/etc/sysconfig/network
  }
  echo 127.0.0.1 ${hostname} >> ${chroot_dir}/etc/hosts
}

# disable mac address caching
printf "[INFO] Unsetting udev 70-persistent-net.rules.\n"
rm -f ${chroot_dir}/etc/udev/rules.d/70-persistent-net.rules
ln -s /dev/null ${chroot_dir}/etc/udev/rules.d/70-persistent-net.rules

[ -z "${execscript}" ] && {
  chroot ${chroot_dir} bash -c "echo root:root | chpasswd"
} || {
  [ -f "${execscript}" ] && {
    [ -x "${execscript}" ] && {
      printf "[INFO] Excecuting after script\n"
      setarch ${distro_arch} ${execscript} ${chroot_dir}
    } || :
  } || :
}

printf "[DEBUG] Unmounting %s\n" ${chroot_dir}/${new_filename}
umount ${chroot_dir}/${new_filename}
printf "[DEBUG] Deleting %s\n" ${chroot_dir}/${tmpdir}
rm -rf ${chroot_dir}/${tmpdir}

printf "[DEBUG] Unmounting %s\n" ${mntpnt}
umount ${mntpnt}

printf "[INFO] Deleting loop devices\n"

tries=0
max_tries=3
while [ ${tries} -lt ${max_tries} ]; do
  kpartx -vd ${disk_filename} && break || :
  tries=$((${tries} + 1))
  sleep 1
  [ ${tries} -ge ${max_tries} ] && printf "[INFO] Could not unmount '%s' after '%d' attempts. Final attempt" ${disk_filename} ${tries}
done
kpartx -vd ${disk_filename} || :

rmdir ${mntpnt}

printf "[INFO] Generated => %s\n" ${disk_filename}
printf "[INFO] Complete!\n"
