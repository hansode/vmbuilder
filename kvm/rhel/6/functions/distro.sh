# -*-Shell-script-*-
#
# description:
#  Linux Distribution
#
# requires:
#  bash
#  cat
#  yum, mkdir, arch
#  chroot, pwconv, chroot, chkconfig, grub
#  cp, rm, ln, touch, rsync
#  find, egrep, sed, xargs
#  mount, umount
#  ls, tail
#
# imports:
#  utils: is_dev, checkroot
#  disk: mkdevice, mkprocdir, mount_proc, umount_nonroot, xptabinfo, mntpntuuid, get_grub_id
#

## depending on global variables

function add_option_distro() {
  distro_arch=${distro_arch:-$(arch)}
  case "${distro_arch}" in
  i*86)   basearch=i386; distro_arch=i686 ;;
  x86_64) basearch=${distro_arch} ;;
  esac

  distro_ver=${distro_ver:-6.3}
  distro_name=${distro_name:-centos}

  keepcache=${keepcache:-0}
  selinux=${selinux:-disabled}

  distro_name=$(get_normalized_distro_name ${distro_name})

  local distro_driver_name="${distro_name}$(get_distro_major_ver ${distro_ver})"
  case "${distro_driver_name}" in
  rhel6|centos6|sl6)
    load_distro_driver ${distro_driver_name}
    ;;
  rhel5|centos5)
    load_distro_driver ${distro_driver_name}
    ;;
  *)
    echo "no mutch distro" >&2
    return 1
    ;;
  esac
}

function load_distro_driver() {
  local distro_driver_name=$1
  [[ -n "${distro_driver_name}" ]] || { echo "[ERROR] Invalid argument: distro_driver_name:${distro_driver_name} (distro:${LINENO})" >&2; return 1; }

  local distro_driver_path=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/distro/${distro_driver_name}.sh
  [[ -f "${distro_driver_path}" ]] || { echo "[ERROR] no such distro driver: ${distro_driver_path} (distro:${LINENO})" >&2; return 1; }

  . ${distro_driver_path}
  add_option_distro_${distro_driver_name}
}

function get_normalized_distro_name() {
  local distro_name=$1
  [[ -n "${distro_name}" ]] || { echo "[ERROR] Invalid argument: distro_name:${distro_name} (distro:${LINENO})" >&2; return 1; }

  case "${distro_name}" in
  rhel)
    echo rhel
    ;;
  centos)
    echo centos
    ;;
  sl|scientific|scientificlinux)
    echo sl
    ;;
  *)
    echo "no mutch distro: ${distro_name}" >&2
    return 1
    ;;
  esac
}

function get_distro_major_ver() {
  local distro_ver=$1
  [[ -n "${distro_ver}" ]] || { echo "[ERROR] Invalid argument: distro_ver:${distro_ver} (distro:${LINENO})" >&2; return 1; }

  # x.y -> x
  echo ${distro_ver%%.*}
}

function preflight_check_distro() {
  case "${baseurl}" in
  http://*)  ;;
  https://*) ;;
  ftp://*)   ;;
  *)
    echo "unknown scheme: ${baseurl}" >&2
    return 1
    ;;
  esac
  printf "[DEBUG] Testing access to %s\n" ${baseurl}
  curl -f -s ${baseurl} >/dev/null || {
    ret=$?
    printf "[ERROR] Could not connect to %s. Please check your connectivity and try again.\n" ${baseurl}
    return ${ret}
  }
}

function distroinfo() {
  cat <<-EOS
	--------------------
	distro_arch: ${distro_arch}
	distro_name: ${distro_name}
	distro_ver:  ${distro_ver}
	chroot_dir:  ${chroot_dir}
	keepcache:   ${keepcache}
	baseurl:     ${baseurl}
	gpgkey:      ${gpgkey}
	--------------------
	EOS
}

function build_chroot() {
  add_option_distro
  preflight_check_distro

  local chroot_dir=${1:-${abs_dirname}/${distro_name}-${distro_ver}_${distro_arch}}
  [[ -d "${chroot_dir}" ]] && { echo "${chroot_dir} already exists (distro:${LINENO})" >&2; return 1; } || :

  distroinfo
  # set_defaults
  bootstrap ${chroot_dir}
  configure_os ${chroot_dir}
  cleanup_distro ${chroot_dir}
}

function bootstrap() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] && { echo "${chroot_dir} already exists (distro:${LINENO})" >&2; return 1; } || :
  checkroot || return 1

  trap "trap_distro ${chroot_dir}" 1 2 3 15

  mkdir -p       ${chroot_dir}
  mkdevice       ${chroot_dir}
  mkprocdir      ${chroot_dir}
  mount_proc     ${chroot_dir}
  run_yum        ${chroot_dir} groupinstall Core
  umount_nonroot ${chroot_dir}
}

## unit functions

function repofile() {
  local reponame=$1 baseurl="$2" gpgkey="$3" keepcache=${4:-0}
  [[ -n "${reponame}" ]] || { echo "[ERROR] Invalid argument: reponame:${reponame} (distro:${LINENO})" >&2; return 1; }
  [[ -n "${baseurl}" ]] || { echo "[ERROR] Invalid argument: baseurl:${baseurl} (distro:${LINENO})" >&2; return 1; }
  [[ -n "${gpgkey}" ]] || { echo "[ERROR] Invalid argument: gpgkey:${gpgkey} (distro:${LINENO})" >&2; return 1; }

  cat <<-EOS
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
	[${reponame}]
	name=${reponame}
	failovermethod=priority
	baseurl=${baseurl}
	enabled=1
	gpgcheck=1
	gpgkey=${gpgkey}
	EOS
}

function run_yum() {
  local chroot_dir=$1; shift
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (distro:${LINENO})" >&2; return 1; }
  # install_kernel depends on distro_name.
  [[ -n "${distro_name}" ]] || { echo "[ERROR] Invalid argument: distro_name:${distro_name} (distro:${LINENO})" >&2; return 1; }

  local reponame=${distro_name}
  local tmpdir=${chroot_dir}/tmp
  local repofile=${tmpdir}/yum-${reponame}.repo

  [[ -d "${tmpdir}" ]] || mkdir ${tmpdir}
  repofile ${reponame} "${baseurl}" "${gpgkey}" ${keepcache:-0} > ${repofile}

  yum \
   -c ${repofile} \
   --disablerepo='*' \
   --enablerepo="${reponame}" \
   --installroot=${chroot_dir} \
   -y \
   $*

  rm -f ${repofile}
}

function configure_mounting() {
  local chroot_dir=$1 disk_filename=$2

  install_fstab ${chroot_dir} ${disk_filename}
}

function update_passwords() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (distro:${LINENO})" >&2; return 1; }

  printf "[INFO] Updating passwords\n"
  chroot ${chroot_dir} pwconv
  chroot ${chroot_dir} bash -c "echo root:root | chpasswd"
}

function create_initial_user() {
  local chroot_dir=$1

  update_passwords ${chroot_dir}
}

function set_timezone() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (distro:${LINENO})" >&2; return 1; }

  printf "[INFO] Setting /etc/localtime\n"
  cp ${chroot_dir}/usr/share/zoneinfo/Japan ${chroot_dir}/etc/localtime
}

function prevent_daemons_starting() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (distro:${LINENO})" >&2; return 1; }

 #local svc= dummy=
 #while read svc dummy; do
 #  chroot ${chroot_dir} chkconfig --del ${svc}
 #done < <(chroot ${chroot_dir} chkconfig --list | egrep -v :on)
}

function install_grub() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (distro:${LINENO})" >&2; return 1; }

  local grub_distro_name=
  for grub_distro_name in redhat unknown; do
    grub_src_dir=${chroot_dir}/usr/share/grub/${basearch}-${grub_distro_name}
    [[ -d "${grub_src_dir}" ]] || continue
    rsync -a ${grub_src_dir}/ ${chroot_dir}/boot/grub/
  done
}

function preferred_initrd() {
  echo ${preferred_initrd:-initramfs}
}

function verify_kernel_installation() {
  local chroot_dir=$1

  ls ${chroot_dir}/boot/vmlinuz-* || { echo "vmlinuz not found (distro:${LINENO})" >&2; return 1; }
  ls ${chroot_dir}/boot/$(preferred_initrd)-* || { echo "$(preferred_initrd) not found (distro:${LINENO})" >&2; return 1; }
}

function install_kernel() {
  local chroot_dir=$1

  #
  # rhel5) run_yum ${chroot_dir} install mkinitrd kernel
  # rhel6) run_yum ${chroot_dir} install dracut kernel
  #
  # if installing kernel, mkinitrd/dracut also will be installed.
  #
  run_yum ${chroot_dir} install kernel
  verify_kernel_installation ${chroot_dir}
}

function install_extras() {
  local chroot_dir=$1

  run_yum ${chroot_dir} install openssh openssh-clients openssh-server rpm yum curl dhclient passwd vim-minimal
}

function erase_selinux() {
  local chroot_dir=$1

  run_yum ${chroot_dir} erase selinux*
}


function install_bootloader_cleanup() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (distro:${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "file not found: ${disk_filename} (distro:${LINENO})" >&2; return 1; }
  checkroot || return 1

  local tmpdir=/tmp/vmbuilder-grub
  is_dev ${disk_filename} || {
    # # ls -1 ${chroot_dir}/${tmpdir}/
    # centos-6.3_x86_64.raw
    # device.map
    local disk=
    while read disk; do
      [[ "${disk}" == "device.map" ]] || umount ${chroot_dir}/${tmpdir}/${disk}
    done < <(ls -1 ${chroot_dir}/${tmpdir}/)
  }
  printf "[DEBUG] Deleting %s\n" ${chroot_dir}/${tmpdir}
  rm -rf ${chroot_dir}/${tmpdir}
}

function install_bootloader() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (distro:${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "file not found: ${disk_filename} (distro:${LINENO})" >&2; return 1; }
  checkroot || return 1

  local root_dev="hd$(get_grub_id)"
  local tmpdir=/tmp/vmbuilder-grub

  mkdir -p ${chroot_dir}/${tmpdir}

  is_dev ${disk_filename} || {
    local new_filename=${tmpdir}/$(basename ${disk_filename})
    touch ${chroot_dir}/${new_filename}
    mount --bind ${disk_filename} ${chroot_dir}/${new_filename}
  }

  local devmapfile=${tmpdir}/device.map
  touch ${chroot_dir}/${devmapfile}
  printf "[INFO] Generating %s\n" ${devmapfile}
  {
    local disk_id=0
    is_dev ${disk_filename} && {
      printf "(hd%d) %s\n" ${disk_id} ${disk_filename}
    } || {
      printf "(hd%d) %s\n" ${disk_id} ${new_filename}
    }
  } >> ${chroot_dir}/${devmapfile}
  cat ${chroot_dir}/${devmapfile}

  printf "[INFO] Installing grub\n"
  install_grub ${chroot_dir}

  local grub_cmd=
  is_dev ${disk_filename} && {
    grub_cmd="grub --device-map=${chroot_dir}/${devmapfile} --batch"
  } || {
    grub_cmd="chroot ${chroot_dir} grub --device-map=${devmapfile} --batch"
  }
  cat <<-_EOS_ | ${grub_cmd}
	root (${root_dev},0)
	setup (hd0)
	quit
	_EOS_

  install_menu_lst ${chroot_dir} ${disk_filename}
  install_bootloader_cleanup ${chroot_dir} ${disk_filename}
}

function install_menu_lst() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (distro:${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "file not found: ${disk_filename} (distro:${LINENO})" >&2; return 1; }

  printf "[INFO] Generating /boot/grub/grub.conf\n"

  local bootdir_path=/boot
  xptabinfo | egrep -q /boot && {
    bootdir_path=
  }

  local grub_id=$(get_grub_id)
  cat <<-_EOS_ > ${chroot_dir}/boot/grub/grub.conf
	default=0
	timeout=5
	splashimage=(hd${grub_id},0)${bootdir_path}/grub/splash.xpm.gz
	hiddenmenu
	title ${distro} ($(cd ${chroot_dir}/boot && ls vmlinuz-* | tail -1 | sed 's,^vmlinuz-,,'))
	        root (hd${grub_id},0)
	        kernel ${bootdir_path}/$(cd ${chroot_dir}/boot && ls vmlinuz-* | tail -1) ro root=UUID=$(mntpntuuid ${disk_filename} root) rd_NO_LUKS rd_NO_LVM LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM
	        initrd ${bootdir_path}/$(cd ${chroot_dir}/boot && ls $(preferred_initrd)-*| tail -1)
	_EOS_
  cat ${chroot_dir}/boot/grub/grub.conf

  cd ${chroot_dir}/boot/grub
  ln -fs grub.conf menu.lst
  cd - >/dev/null
}

function configure_os() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (distro:${LINENO})" >&2; return 1; }
  checkroot || return 1

  mount_proc               ${chroot_dir}
  mount_dev                ${chroot_dir}

  # TODO
  #  should use configure_selinux,
  #  but configure_selinux has an issue which don't allow logging in by root without erasing selinux.
 #configure_selinux        ${chroot_dir} ${selinux}
  erase_selinux            ${chroot_dir}

  # TODO
  #  should decide where the better place is distro or hypervisor or both.
  #  so far following three functions are defined in distro.
  prevent_daemons_starting ${chroot_dir}
  create_initial_user      ${chroot_dir}
  set_timezone             ${chroot_dir}

  install_resolv_conf      ${chroot_dir}
  install_extras           ${chroot_dir}
  umount_nonroot           ${chroot_dir}
}

function configure_networking() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (distro:${LINENO})" >&2; return 1; }

  cat <<-EOS > ${chroot_dir}/etc/sysconfig/network
	NETWORKING=yes
	EOS
  config_host_and_domainname ${chroot_dir}
  config_interfaces          ${chroot_dir}

  local udev_70_persistent_net_path=${chroot_dir}/etc/udev/rules.d/70-persistent-net.rules
  printf "[INFO] Unsetting udev 70-persistent-net.rules\n"
  [[ -a "${udev_70_persistent_net_path}" ]] && rm -f ${udev_70_persistent_net_path} || :
  ln -s /dev/null ${udev_70_persistent_net_path}
}

function config_host_and_domainname() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (distro:${LINENO})" >&2; return 1; }

  cat <<-EOS > ${chroot_dir}/etc/hosts
	127.0.0.1       localhost
	EOS

  [[ -z "${hostname}" ]] || {
    printf "[INFO] Setting hostname: %s\n" ${hostname}
    [[ -f ${chroot_dir}/etc/sysconfig/network ]] || {
      echo HOSTNAME=${hostname} > ${chroot_dir}/etc/sysconfig/network
    }
    egrep ^HOSTNAME= ${chroot_dir}/etc/sysconfig/network -q && {
      sed -i "s,^HOSTNAME=.*,HOSTNAME=${hostname}," ${chroot_dir}/etc/sysconfig/network
    } || {
      echo HOSTNAME=${hostname} >> ${chroot_dir}/etc/sysconfig/network
    }
    cat ${chroot_dir}/etc/sysconfig/network
    echo 127.0.0.1 ${hostname} >> ${chroot_dir}/etc/hosts
    cat ${chroot_dir}/etc/hosts
  }

  printf "[INFO] Generating /etc/resolv.conf\n"
  [[ -z "${dns}" ]] || {
    cat <<-EOS > ${chroot_dir}/etc/resolv.conf
	nameserver ${dns}
	EOS
  }
  [[ -f ${chroot_dir}/etc/resolv.conf ]] && cat ${chroot_dir}/etc/resolv.conf || :
}

function config_interfaces() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (distro:${LINENO})" >&2; return 1; }

  local ifindex=0
  local ifname=eth${ifindex}
  local ifcfg_path=/etc/sysconfig/network-scripts/ifcfg-${ifname}

  printf "[INFO] Generating %s\n" ${ifcfg_path}
  [[ -z "${ip}" ]] && {
    cat <<-EOS > ${chroot_dir}${ifcfg_path}
	DEVICE=${ifname}
	BOOTPROTO=dhcp
	ONBOOT=yes
	EOS
  } || {
    cat <<-EOS > ${chroot_dir}${ifcfg_path}
	DEVICE=${ifname}
	BOOTPROTO=static
	ONBOOT=yes
	IPADDR=${ip}
	$([[ -z "${net}"   ]] || echo "NETMASK=${net}")
	$([[ -z "${bcast}" ]] || echo "BROADCAST=${bcast}")
	$([[ -z "${gw}"    ]] || echo "GATEWAY=${gw}")
	EOS
  }
  cat ${chroot_dir}${ifcfg_path}
}

function install_resolv_conf() {
  local chroot_dir=$1

  cat <<-EOS > ${chroot_dir}/etc/resolv.conf
	nameserver 8.8.8.8
	EOS
}

function install_fstab() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (distro:${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "file not found: ${disk_filename} (distro:${LINENO})" >&2; return 1; }
  checkroot || return 1

  printf "[INFO] Overwriting /etc/fstab\n"
  {
  local default_filesystem=$(preferred_filesystem)
  xptabproc <<'EOS'
    case "${mountpoint}" in
    /boot) fstype=${default_filesystem} dumpopt=1 fsckopt=2 mountpath=${mountpoint} ;;
    root)  fstype=${default_filesystem} dumpopt=1 fsckopt=1 mountpath=/             ;;
    swap)  fstype=swap                  dumpopt=0 fsckopt=0 mountpath=${mountpoint} ;;
    /opt)  fstype=${default_filesystem} dumpopt=1 fsckopt=1 mountpath=${mountpoint} ;;
    /home) fstype=${default_filesystem} dumpopt=1 fsckopt=2 mountpath=${mountpoint} ;;
    *)     fstype=${default_filesystem} dumpopt=1 fsckopt=1 mountpath=${mountpoint} ;;
    esac
    uuid=$(mntpntuuid ${disk_filename} ${mountpoint})
    printf "UUID=%s %s\t%s\tdefaults\t%s %s\n" ${uuid} ${mountpath} ${fstype} ${dumpopt} ${fsckopt}
EOS
  cat <<-_EOS_
	tmpfs                   /dev/shm                tmpfs   defaults        0 0
	devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
	sysfs                   /sys                    sysfs   defaults        0 0
	proc                    /proc                   proc    defaults        0 0
	_EOS_
  } > ${chroot_dir}/etc/fstab
  cat ${chroot_dir}/etc/fstab
}

function configure_keepcache() {
  local chroot_dir=$1 keepcache=${2:-0}

  case "${keepcache}" in
  [01]) ;;
  *)    keepcache=0 ;;
  esac
  [[ -a "${chroot_dir}/etc/yum.conf" ]] || { echo "file not found: ${chroot_dir}/etc/yum.conf (distro:${LINENO})" >&2; return 1; }
  printf "[INFO] Setting /etc/yum.conf: keepcache=%s\n" ${keepcache}
  sed -i s,^keepcache=.*,keepcache=${keepcache}, ${chroot_dir}/etc/yum.conf
  egrep ^keepcache= ${chroot_dir}/etc/yum.conf
}

function configure_selinux() {
  local chroot_dir=$1 selinux=${2:-disabled}
  [[ -a "${chroot_dir}/etc/sysconfig/selinux" ]] || return 0

  case "${selinux}" in
  enforcing|permissive|disabled)
    ;;
  *)
    echo "[ERROR] unknown SELINUX value: ${selinux} (distro:${LINENO})" >&2
    return 1
    ;;
  esac
  printf "[INFO] Setting /etc/sysconfig/selinux: SELINUX=%s\n" ${selinux}
  sed -i "s/^\(SELINUX=\).*/\1${selinux}/"  ${chroot_dir}/etc/sysconfig/selinux
  egrep ^SELINUX= ${chroot_dir}/etc/sysconfig/selinux
}

function cleanup_distro() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (distro:${LINENO})" >&2; return 1; }

  find   ${chroot_dir}/var/log/ -type f | xargs rm
  rm -rf ${chroot_dir}/tmp/*
}

function preferred_filesystem() {
  echo ${preferred_filesystem:-ext3}
}

##

function trap_distro() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir} (distro:${LINENO})" >&2; return 1; }

  umount_nonroot ${chroot_dir}
  [[ -d "${chroot_dir}" ]] && rm -rf ${chroot_dir}
}
