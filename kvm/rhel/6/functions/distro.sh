# -*-Shell-script-*-
#
# description:
#  Linux Distribution
#
# requires:
#  bash, basename
#  cat, curl
#  rpm, yum, mkdir, arch
#  pwconv, chkconfig, grub, grub2-mkconfig, grub2-set-default
#  cp, rm, ln, touch, rsync
#  find, egrep, grep, sed, xargs
#  mount, umount
#  ls, tail
#
# imports:
#  utils: checkroot, run_in_target, expand_path
#  disk: is_dev, mkdevice, mkprocdir, mount_proc, umount_nonroot, xptabinfo, mntpntuuid, get_grub_id, lsdevmap, devmap2lodev
#

## depending on global variables

function add_option_distro() {
  distro_arch=${distro_arch:-$(arch)}
  case "${distro_arch}" in
  i*86)   basearch=i386 distro_arch=i686 ;;
  x86_64) basearch=${distro_arch} ;;
  esac

  distro_name=${distro_name}
  distro_ver=${distro_ver}

  keepcache=${keepcache:-0}
  selinux=${selinux:-0}

  distro_name=$(get_normalized_distro_name ${distro_name})

  local driver_name="${distro_name}$(get_distro_major_ver ${distro_ver})"
  case "${driver_name}" in
  rhel6|centos6|sl6)
    load_distro_driver ${driver_name}
    ;;
  rhel5|centos5)
    load_distro_driver ${driver_name}
    ;;
  rhel4|centos4)
    load_distro_driver ${driver_name}
    ;;
  fedora[7-9]|fedora1[0-7])
    load_distro_driver ${driver_name}
    ;;
  *)
    echo "[ERROR] no mutch distro ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2
    return 1
    ;;
  esac

  addpkg=${addpkg:-}
  epel_uri=${epel_uri:-}
  nictab=${nictab:-}
  routetab=${routetab:-}

 #domain=${domain:-}
  ip=${ip:-}
  mask=${mask:-}
  net=${net:-}
  bcast=${bcast:-}
  gw=${gw:-}
  dns=${dns:-}
  hostname=${hostname:-}

  # settings for the initial user
  devel_user=${devel_user:-}
  devel_pass=${devel_pass:-}

  rootpass=${rootpass:-}

  ssh_key=${ssh_key:-}
  ssh_user_key=${ssh_user_key:-}
}

function load_distro_driver() {
  local driver_name=$1
  [[ -n "${driver_name}" ]] || { echo "[ERROR] Invalid argument: driver_name:${driver_name} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  local distro_driver_path=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/distro/${driver_name}.sh
  [[ -f "${distro_driver_path}" ]] || { echo "[ERROR] no such distro driver: ${distro_driver_path} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  . ${distro_driver_path}
  add_option_distro_${driver_name}
}

## distro info

function get_normalized_distro_name() {
  local distro_name=$1
  [[ -n "${distro_name}" ]] || { echo "[ERROR] Invalid argument: distro_name:${distro_name} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

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
  fedora)
    echo fedora
    ;;
  *)
    echo "[ERROR] no mutch $(basename ${BASH_SOURCE[0]}): ${distro_name} (distro:${LINENO})" >&2
    return 1
    ;;
  esac
}

function get_distro_major_ver() {
  local distro_ver=$1
  [[ -n "${distro_ver}" ]] || { echo "[ERROR] Invalid argument: distro_ver:${distro_ver} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  # x.y -> x
  echo ${distro_ver%%.*}
}

function preflight_check_uri() {
  local uri=$1
  [[ -n "${uri}" ]] || { echo "[ERROR] Invalid argument: uri:${uri} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  case "${uri}" in
  http://*)  ;;
  https://*) ;;
  ftp://*)   ;;
  *)
    echo "[ERROR] unknown scheme: ${uri} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2
    return 1
    ;;
  esac
  printf "[DEBUG] Testing access to %s\n" ${uri}
  curl -f -s ${uri} >/dev/null || {
    ret=$?
    printf "[ERROR] Could not connect to %s. Please check your connectivity and try again.\n" ${uri}
    return ${ret}
  }
}

function preflight_check_distro() {
  [[ -n "${baseurl}" ]] || { echo "[ERROR] Invalid argument: baseurl:${baseurl} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  preflight_check_uri "${baseurl}" || return 1

  [[ -n "${gpgkey}" ]] || { echo "[ERROR] Invalid argument: gpgkey:${gpgkey} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  for i in ${gpgkey}; do
    preflight_check_uri "${i}" || return 1
  done
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

## chroot distro tree

function build_chroot() {
  add_option_distro
  preflight_check_distro

  local chroot_dir=${1:-$(pwd)/${distro_name}-${distro_ver}_${distro_arch}}
  [[ -d "${chroot_dir}" ]] && { echo "[ERROR] ${chroot_dir} already exists ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; } || :

  distroinfo
  # set_defaults
  bootstrap      ${chroot_dir}
  configure_os   ${chroot_dir}
  cleanup_distro ${chroot_dir}
}

function cleanup_distro() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  find   ${chroot_dir}/var/log/ -type f | xargs rm
  rm -rf ${chroot_dir}/tmp/*
}

## bootstrap

function trap_distro() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  echo "[DEBUG] trap_distro fired"

  umount_nonroot ${chroot_dir}
  [[ -d "${chroot_dir}" ]] && rm -rf ${chroot_dir}
}

function bootstrap() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] && { echo "[ERROR] ${chroot_dir} already exists ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; } || :
  checkroot || return 1

  trap "trap_distro ${chroot_dir}" ERR

  mkdir -p       ${chroot_dir}
  mkdevice       ${chroot_dir}
  mkprocdir      ${chroot_dir}
  mount_proc     ${chroot_dir}
  run_yum        ${chroot_dir} groupinstall Core
  umount_nonroot ${chroot_dir}
}

## os configuration

function configure_os() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  checkroot || return 1

  mount_proc               ${chroot_dir}
  mount_dev                ${chroot_dir}

  # TODO
  #  should decide where the better place is distro or hypervisor or both.
  #  so far following three functions are defined in distro.
  prevent_daemons_starting ${chroot_dir}
  # moved to hypervisor in order to use cached distro dir
 #create_initial_user      ${chroot_dir}
  set_timezone             ${chroot_dir}

  install_resolv_conf      ${chroot_dir}
  install_extras           ${chroot_dir}
  umount_nonroot           ${chroot_dir}
}

## container

function configure_container() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  # make sure to make device files & directories at post install phase
  mkdevice              ${chroot_dir}

  prevent_udev_starting ${chroot_dir}
  reconfigure_fstab     ${chroot_dir}
  reconfigure_mtab      ${chroot_dir}
}

function configure_openvz() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  install_vzkernel          ${chroot_dir}
  install_vzutils           ${chroot_dir}
  install_menu_lst_vzkernel ${chroot_dir}
}

## yum

function repofile() {
  local reponame=$1 baseurl="$2" gpgkey="$3" keepcache=${4:-0}
  [[ -n "${reponame}" ]] || { echo "[ERROR] Invalid argument: reponame:${reponame} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -n "${baseurl}"  ]] || { echo "[ERROR] Invalid argument: baseurl:${baseurl} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -n "${gpgkey}"   ]] || { echo "[ERROR] Invalid argument: gpgkey:${gpgkey} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

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
  [[ -d "${chroot_dir}"  ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  # install_kernel depends on distro_name.
  [[ -n "${distro_name}" ]] || { echo "[ERROR] Invalid argument: distro_name:${distro_name} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  local reponame=${distro_name}
  local tmpdir=${chroot_dir}/tmp
  local repofile=${tmpdir}/yum-${reponame}.repo

  [[ -d "${tmpdir}" ]] || mkdir ${tmpdir}
  repofile ${reponame} "${baseurl}" "${gpgkey}" ${keepcache:-0} > ${repofile}

  yum \
   -c ${repofile} \
   --disablerepo='*' \
   --enablerepo="${reponame}" \
   --installroot=$(expand_path ${chroot_dir}) \
   -y \
   $*

  rm -f ${repofile}
}

function configure_keepcache() {
  local chroot_dir=$1 keepcache=${2:-0}
  [[ -a "${chroot_dir}/etc/yum.conf" ]] || { echo "[ERROR] file not found: ${chroot_dir}/etc/yum.conf ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  case "${keepcache}" in
  [01]) ;;
  *)    keepcache=0 ;;
  esac

  printf "[INFO] Setting /etc/yum.conf: keepcache=%s\n" ${keepcache}
  egrep -q ^keepcache= ${chroot_dir}/etc/yum.conf || {
    echo keepcache=${keepcache} >> ${chroot_dir}/etc/yum.conf
  } || {
    sed -i "s,^keepcache=.*,keepcache=${keepcache}," ${chroot_dir}/etc/yum.conf
  }

  egrep ^keepcache= ${chroot_dir}/etc/yum.conf
}

## other system configuration

function configure_selinux() {
  local chroot_dir=$1 selinux=${2:-0}
  [[ -a "${chroot_dir}/etc/sysconfig/selinux" ]] || { echo "[ERROR] file not found: ${chroot_dir}/etc/sysconfig/selinux ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  printf "[INFO] Setting /etc/sysconfig/selinux: SELINUX=%s\n" ${selinux}
  case "${selinux}" in
  0)
    sed -i "s/^\(SELINUX=\).*/\1disabled/" ${chroot_dir}/etc/sysconfig/selinux
    egrep ^SELINUX= ${chroot_dir}/etc/sysconfig/selinux
    ;;
  esac
  cat ${chroot_dir}/etc/sysconfig/selinux
}

function set_timezone() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  printf "[INFO] Setting /etc/localtime\n"
  cp ${chroot_dir}/usr/share/zoneinfo/Japan ${chroot_dir}/etc/localtime
}

function prevent_daemons_starting() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

 #local svc= dummy=
 #while read svc dummy; do
 #  run_in_target ${chroot_dir} chkconfig --del ${svc}
 #done < <(run_in_target ${chroot_dir} chkconfig --list | egrep -v :on)
}

function prevent_udev_starting() {
  local chroot_dir=$1

  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  sed -i 's,/sbin/start_udev,#\0,' \
    ${chroot_dir}/etc/rc.sysinit   \
    ${chroot_dir}/etc/rc.d/rc.sysinit
}

## mounting

function configure_mounting() {
  local chroot_dir=$1 disk_filename=$2

  install_fstab ${chroot_dir} ${disk_filename}
}

function preferred_filesystem() {
  echo ${preferred_filesystem:-ext3}
}

function install_fstab() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
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
  render_fstab
  } > ${chroot_dir}/etc/fstab
  cat ${chroot_dir}/etc/fstab
}

function render_fstab() {
  cat <<-_EOS_
	tmpfs                   /dev/shm                tmpfs   defaults        0 0
	devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
	sysfs                   /sys                    sysfs   defaults        0 0
	proc                    /proc                   proc    defaults        0 0
	_EOS_
}

function reconfigure_fstab() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  render_fstab ${chroot_dir} | tee ${chroot_dir}/etc/fstab
}

function reconfigure_mtab() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  [[ -f "${chroot_dir}/etc/mtab" ]] && rm -f ${chroot_dir}/etc/mtab || :
  run_in_target ${chroot_dir} ln -fs /proc/mounts /etc/mtab
}

## unix user

function update_passwords() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  printf "[INFO] Updating passwords\n"
  run_in_target ${chroot_dir} pwconv
  run_in_target ${chroot_dir} "echo root:${rootpass:-root} | chpasswd"

  [[ -z "${devel_user}" ]] || {
    run_in_target ${chroot_dir} "echo ${devel_user}:${devel_pass:-${devel_user}} | chpasswd"
  }
}

function create_initial_user() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  [[ -z "${devel_user}" ]] || {
    printf "[INFO] Creating user: %s\n" ${devel_user}

    local devel_group=${devel_user}
    local devel_home=/home/${devel_user}

    run_in_target ${chroot_dir} "getent group  ${devel_group} >/dev/null || groupadd ${devel_group}"
    run_in_target ${chroot_dir} "getent passwd ${devel_user}  >/dev/null || useradd -g ${devel_group} -d ${devel_home} -s /bin/bash -m ${devel_user}"

    egrep -q ^umask ${chroot_dir}/${devel_home}/.bashrc || {
      echo umask 022 >> ${chroot_dir}/${devel_home}/.bashrc
    }

    egrep ^${devel_user} -w ${chroot_dir}/etc/sudoers || { echo "${devel_user} ALL=(ALL) NOPASSWD: ALL" >> ${chroot_dir}/etc/sudoers; }
  }

  update_passwords ${chroot_dir}
}

function install_authorized_keys() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  [[ -f "${ssh_key}" ]] && {
    printf "[INFO] Installing authorized_keys %s\n" /root/.ssh/authorized_keys
    mkdir -m 0700 ${chroot_dir}/root/.ssh
    rsync -a ${ssh_key} ${chroot_dir}/root/.ssh/authorized_keys
    chmod 0644 ${chroot_dir}/root/.ssh/authorized_keys
  } || :

  [[ -f "${ssh_user_key}" && -n "${devel_user}" ]] && {
    printf "[INFO] Installing authorized_keys %s\n" /home/${devel_user}/.ssh/authorized_keys
    mkdir -m 0700 ${chroot_dir}/home/${devel_user}/.ssh
    rsync -a ${ssh_user_key} ${chroot_dir}/home/${devel_user}/.ssh/authorized_keys
    chmod 0644  ${chroot_dir}/home/${devel_user}/.ssh/authorized_keys
    run_in_target ${chroot_dir} "chown -R ${devel_user}:${devel_user} /home/${devel_user}/.ssh/"
  } || :
}

## package configuration

### vanilla kernel

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

function install_addedpkgs() {
  local chroot_dir=$1

  [[ -z "${addpkg}" ]] || run_yum ${chroot_dir} install ${addpkg}
}

function install_epel() {
  local chroot_dir=$1

  # need to periodically update uri
  # ex) http://ftp.riken.jp/Linux/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
  [[ -z "${epel_uri}" ]] || run_in_target ${chroot_dir} yum install -y ${epel_uri}
}

### openvz kernel

function install_vzkernel() {
  local chroot_dir=$1

  [[ -f ${chroot_dir}/etc/yum.repos.d/openvz.repo ]] || {
    curl http://download.openvz.org/openvz.repo -o ${chroot_dir}/etc/yum.repos.d/openvz.repo
  }

  run_in_target ${chroot_dir} yum install -y vzkernel
  verify_kernel_installation ${chroot_dir}
}

function install_vzutils() {
  local chroot_dir=$1

  run_in_target ${chroot_dir} yum install -y vzctl vzquota
}

## kernel configuration

function preferred_initrd() {
  echo ${preferred_initrd:-initramfs}
}

function verify_kernel_installation() {
  local chroot_dir=$1

  ls ${chroot_dir}/boot/vmlinuz-*             || { echo "[ERROR] vmlinuz not found ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  ls ${chroot_dir}/boot/$(preferred_initrd)-* || { echo "[ERROR] $(preferred_initrd) not found ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
}

## grub configuration

function preferred_grub() {
  echo ${preferred_grub:-grub}
}

function install_grub() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  local grub_distro_name=
  for grub_distro_name in redhat unknown; do
    grub_src_dir=${chroot_dir}/usr/share/grub/${basearch}-${grub_distro_name}
    [[ -d "${grub_src_dir}" ]] || continue
    rsync -a ${grub_src_dir}/ ${chroot_dir}/boot/grub/
  done
}

function install_grub2() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  # fedora >= 16 should be used not grub but grub2
  run_yum ${chroot_dir} install grub2
}

## bootloader configuration

### vanilla kernel

function install_bootloader_cleanup() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
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
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
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

  local grub_cmd=
  case "$(preferred_grub)" in
  grub)
    grub_cmd="grub --batch"
    install_grub ${chroot_dir}
    ;;
  grub2)
    local target_device=
    is_dev ${disk_filename} && {
      target_device="${disk_filename}"
    } || {
      target_device="$(lsdevmap ${disk_filename} | devmap2lodev)"
    }
    grub_cmd="grub2-setup ${target_device}"

    install_grub2 ${chroot_dir}
    run_in_target ${chroot_dir} grub2-install ${target_device}
    ;;
  esac

  is_dev ${disk_filename} && {
    grub_cmd="${grub_cmd} --device-map=${chroot_dir}/${devmapfile}"
  } || {
    grub_cmd="run_in_target ${chroot_dir} ${grub_cmd} --device-map=${devmapfile}"
  }

  case "$(preferred_grub)" in
  grub)
    cat <<-_EOS_ | ${grub_cmd}
	root (${root_dev},0)
	setup (hd0)
	quit
	_EOS_
    ;;
  grub2)
    ${grub_cmd}
    ;;
  esac

  install_menu_lst           ${chroot_dir} ${disk_filename}
  install_bootloader_cleanup ${chroot_dir} ${disk_filename}
}

## grub_menu_list configuration

function install_menu_lst() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  case "$(preferred_grub)" in
  grub)  install_menu_lst_grub  ${chroot_dir} ${disk_filename} ;;
  grub2) install_menu_lst_grub2 ${chroot_dir} ${disk_filename} ;;
  esac
}

function install_menu_lst_grub() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

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
	        kernel ${bootdir_path}/$(cd ${chroot_dir}/boot && ls vmlinuz-* | tail -1) ro root=UUID=$(mntpntuuid ${disk_filename} root) rd_NO_LUKS rd_NO_LVM LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM selinux=${selinux:-0}
	        initrd ${bootdir_path}/$(cd ${chroot_dir}/boot && ls $(preferred_initrd)-*| tail -1)
	_EOS_
  cat ${chroot_dir}/boot/grub/grub.conf

  cd ${chroot_dir}/boot/grub
  ln -fs grub.conf menu.lst
  cd - >/dev/null

  run_in_target ${chroot_dir} ln -fs /boot/grub/grub.conf /etc/grub.conf
}

function install_menu_lst_grub2() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  printf "[INFO] Generating /boot/grub2/grub.cfg\n"

  run_in_target ${chroot_dir} grub2-mkconfig -o /boot/grub2/grub.cfg
  run_in_target ${chroot_dir} grub2-set-default 0

  mangle_grub_menu_lst_grub2 ${chroot_dir} ${disk_filename}

  cat ${chroot_dir}/boot/grub2/grub.cfg
}

function mangle_grub_menu_lst_grub2() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  local bootdir_path=/boot
  xptabinfo | egrep -q /boot && {
    bootdir_path=
  }

  # - set root='(/dev/loop0,msdos1)'
  # + set root='(hd0,0)'
  local grub_id=$(get_grub_id)
  sed -i "s|set root=[^ ]*|set root='(hd${grub_id},0)'|" ${chroot_dir}/boot/grub2/grub.cfg

  # - linux   /boot/vmlinuz-3.1.0-7.fc16.x86_64 root=/dev/mapper/loop0p1 ro quiet rhgb
  # + linux   ${bootdir_path}/vmlinuz-3.1.0-7.fc16.x86_64 root=UUID=$(mntpntuuid ${disk_filename} root) ro quiet rhgb

  sed -i "s,/boot,${bootdir_path}," ${chroot_dir}/boot/grub2/grub.cfg
  sed -i "s,root=/[^ ]*,root=UUID=$(mntpntuuid ${disk_filename} root)," ${chroot_dir}/boot/grub2/grub.cfg

  # show booting progress
  sed -i "s,quiet rhgb,," ${chroot_dir}/boot/grub2/grub.cfg
}

### openvz kernel

function vzkernel_version() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  run_in_target ${chroot_dir} rpm -q --qf '%{Version}-%{Release}' vzkernel
}

function install_menu_lst_vzkernel() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}"                     ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -a "${chroot_dir}/etc/fstab"           ]] || { echo "[WARN] file not found: ${chroot_dir}/etc/fstab ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 0; }
  [[ -a "${chroot_dir}/boot/grub/grub.conf" ]] || { echo "[ERROR] file not found: ${chroot_dir}/boot/grub/grub.conf ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  local version=$(vzkernel_version ${chroot_dir})
  [[ -n "${version}" ]] || { echo "[ERROR] vzkernel not found ($(basename ${BASH_SOURCE[0]}):${LINENO})" &2; return 1; }

  local bootdir_path=
  local root_dev=$(awk '$2 == "/boot" {print $1}' ${chroot_dir}/etc/fstab)

  [[ -n "${root_dev}" ]] || {
    # has no /boot partition case
    root_dev=$(awk '$2 == "/" {print $1}' ${chroot_dir}/etc/fstab)
    bootdir_path=/boot
  }

  local grub_title="OpenVZ (${version})"
  cat <<-_EOS_ >> ${chroot_dir}/boot/grub/grub.conf
	title ${grub_title}
	        root (hd0,0)
	        kernel ${bootdir_path}/vmlinuz-${version} ro root=${root_dev} rd_NO_LUKS rd_NO_LVM LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM selinux=${selinux:-0}
	        initrd ${bootdir_path}/initramfs-${version}.img
	_EOS_

  # set default kernel
  # *** "grep" should be used at after 'cat -n'. because ${grub_title} includes regex meta characters. ex. '(' and ')'. ***
  local menu_order=$(egrep ^title ${chroot_dir}/boot/grub/grub.conf | cat -n | grep "${grub_title}" | tail | awk '{print $1}')
  local menu_offset=0
  [[ -z "${menu_order}" ]] || {
    menu_offset=$((${menu_order} - 1))
  }
  sed -i "s,^default=.*,default=${menu_offset}," ${chroot_dir}/boot/grub/grub.conf
  cat ${chroot_dir}/boot/grub/grub.conf
}

## networking configuration

function install_resolv_conf() {
  local chroot_dir=$1

  cat <<-EOS > ${chroot_dir}/etc/resolv.conf
	nameserver 8.8.8.8
	EOS
}

function configure_networking() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  cat <<-EOS > ${chroot_dir}/etc/sysconfig/network
	NETWORKING=yes
	EOS
  config_host_and_domainname ${chroot_dir}
  config_interfaces          ${chroot_dir}
  config_routing             ${chroot_dir}

  local udev_70_persistent_net_path=${chroot_dir}/etc/udev/rules.d/70-persistent-net.rules
  printf "[INFO] Unsetting udev 70-persistent-net.rules\n"
  [[ -a "${udev_70_persistent_net_path}" ]] && rm -f ${udev_70_persistent_net_path} || :
  ln -s /dev/null ${udev_70_persistent_net_path}
}

function config_host_and_domainname() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

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

function configure_console() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  printf "[INFO] Configuring console\n"
  [[ -f ${chroot_dir}/etc/sysconfig/init ]] && {
    sed -i "s,^ACTIVE_CONSOLES=.*,ACTIVE_CONSOLES=\"/dev/tty[1-6] /dev/ttyS0\"", ${chroot_dir}/etc/sysconfig/init
  } || :

  egrep -w "^ttyS0" ${chroot_dir}/etc/securetty || { echo ttyS0 >>  ${chroot_dir}/etc/securetty; }
}

## nic configuration

function nictabinfo() {
  {
    [[ -n "${nictab}" && -f "${nictab}" ]] && {
      cat ${nictab}
    } || {
      cat <<-EOS
	ifname=eth0 ip=${ip} mask=${mask} net=${net} bcast=${bcast} gw=${gw} onboot=${onboot} iftype=ethernet
	EOS
    }
  } | egrep -v '^$|^#'
}

function config_interfaces() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  local line=
  while read line; do
    (
      ifname= ip= mask= net= bcast= gw= onboot= iftype=
      eval ${line}
      install_interface ${chroot_dir} ${ifname} ${iftype}
    )
  done < <(nictabinfo)
}

function install_interface() {
  local chroot_dir=$1 ifname=${2:-eth0} iftype=${3:-ethernet}
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  local ifcfg_path=/etc/sysconfig/network-scripts/ifcfg-${ifname}

  printf "[INFO] Generating %s\n" ${ifcfg_path}

  iftype=$(echo ${iftype} | tr A-Z a-z)
  case ${iftype} in
  ethernet|ovsbridge)
    ;;
  bridge)
    run_yum ${chroot_dir} install bridge-utils
    ;;
  *)
    echo "[ERROR] no mutch iftype: ${iftype} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2
    return 1
    ;;
  esac

  {
    render_interface_${iftype} ${ifname}
    render_interface_netowrk_configuration
  } | egrep -v '^$' > ${chroot_dir}/${ifcfg_path}
  cat ${chroot_dir}/${ifcfg_path}
}

function render_interface_netowrk_configuration() {
  [[ -z "${ip}" ]] && {
    local bootproto

    [[ -z "${bridge}" ]] && {
      bootproto=dhcp
    } || {
      bootproto=none
    }

    cat <<-EOS
	BOOTPROTO=${bootproto}
	EOS
  } || {
    cat <<-EOS
	BOOTPROTO=static
	IPADDR=${ip}
	$([[ -z "${mask}"   ]] || echo "NETMASK=${mask}")
	$([[ -z "${net}"    ]] || echo "NETWORK=${net}")
	$([[ -z "${bcast}"  ]] || echo "BROADCAST=${bcast}")
	$([[ -z "${gw}"     ]] || echo "GATEWAY=${gw}")
	EOS
  }

  cat <<-EOS
	ONBOOT=${onboot:-yes}
	EOS
}

function render_interface_ethernet() {
  local ifname=${1:-eth0}

  cat <<-EOS
	DEVICE=${ifname}
	TYPE=Ethernet
	$([[ -z "${bridge}" ]] || echo "BRIDGE=${bridge}")
	EOS
}

function render_interface_bridge() {
  local ifname=${1:-br0}

  cat <<-EOS
	DEVICE=${ifname}
	TYPE=Bridge
	EOS
}

function render_interface_ovsbridge() {
  local ifname=${1:-br0}

  cat <<-EOS
	DEVICE=${ifname}
	TYPE=OVSBridge
	NM_CONTROLLED=no
	DEVICETYPE=ovs
	OVS_EXTRA="\\
	 set bridge     \${DEVICE} other_config:disable-in-band=true --\\
	 set-fail-mode  \${DEVICE} secure --\\
	 set-controller \${DEVICE} unix:/var/run/openvswitch/\${DEVICE}.controller
	"
	EOS
}

## routing configuration

function routetabinfo() {
  [[ -n "${routetab}" && -f "${routetab}" ]] || return 0

  egrep -v '^$|^#' ${routetab}
}

function config_routing() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  local line=
  while read line; do
    (
      ifname= cidr= gw=
      eval ${line}
      install_routing ${chroot_dir} ${ifname}
    )
  done < <(routetabinfo)
}

function install_routing() {
  local chroot_dir=$1 ifname=$2
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }
  [[ -n "${ifname}" ]] || { echo "[ERROR] Invalid argument: ifname:${ifname} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  local route_path=/etc/sysconfig/network-scripts/route-${ifname}

  printf "[INFO] Generating %s\n" ${route_path}

  render_routing ${ifname} | egrep -v '^$' >> ${chroot_dir}/${route_path}
  cat ${chroot_dir}/${route_path}
}

function render_routing() {
  local ifname=$1
  [[ -n "${ifname}" ]] || { echo "[ERROR] Invalid argument: ifname:${ifname} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  # ip command arguments format
  # - default X.X.X.X dev interface
  # - X.X.X.X/X via X.X.X.X dev interface

  case "${cidr}" in
  "")
    # gw=x.x.x.x ifname=ethX
    cat <<-EOS
	default ${gw} dev ${ifname}
	EOS
	;;
  *)
    # cidr=x.x.x.x/x gw=x.x.x.x ifname=ethX
    cat <<-EOS
	${cidr} via ${gw} dev ${ifname}
	EOS
	;;
  esac
}

## detector

function detect_distro() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} ($(basename ${BASH_SOURCE[0]}):${LINENO})" >&2; return 1; }

  # * /etc/lsb-release
  # DISTRIB_ID=Ubuntu
  # DISTRIB_RELEASE=10.04
  # DISTRIB_CODENAME=lucid
  # DISTRIB_DESCRIPTION="Ubuntu 10.04.3 LTS"
  #
  # * /etc/redhat-release
  # CentOS release 5.6 (Final)
  # CentOS Linux release 6.0 (Final)
  # Red Hat Enterprise Linux Server release 6.0 (Santiago)
  # Scientific Linux release 6.0 (Carbon)

  local DISTRIB_ID=
  local DISTRIB_RELEASE=
  local DISTRIB_FLAVOR=

  if [[ -f "${chroot_dir}/etc/redhat-release" ]]; then
    # rhel
    DISTRIB_FLAVOR=RedHat
    if [[ -f "${chroot_dir}/etc/centos-release" ]]; then
      DISTRIB_ID=CentOS
    elif [[ -f "${chroot_dir}/etc/fedora-release" ]]; then
      DISTRIB_ID=Fedora
    else
      # rhel, scientific
      case "$(sed 's,Linux .*,,; s, ,,g' ${chroot_dir}/etc/redhat-release)" in
      Scientific)
        DISTRIB_ID=Scientific
        ;;
      RedHatEnterprise)
        DISTRIB_ID=RHEL
        ;;
      CentOS*)
        # 5.x
        DISTRIB_ID=CentOS
        ;;
      *)
        DISTRIB_ID=Unknown
        ;;
      esac
    fi
    DISTRIB_RELEASE=$(sed -e 's/.*release \(.*\) .*/\1/' ${chroot_dir}/etc/redhat-release)
  elif [[ -f "${chroot_dir}/etc/debian_version" ]]; then
    # debian
    DISTRIB_FLAVOR=Debian
    if [[ -f "${chroot_dir}/etc/lsb-release" ]]; then
      . ${chroot_dir}/etc/lsb-release
    else
      DISTRIB_ID=Debian
    fi
  else
    # others
    DISTRIB_ID=Unknown
  fi

  cat <<-EOS
	DISTRIB_FLAVOR=${DISTRIB_FLAVOR}
	DISTRIB_ID=${DISTRIB_ID}
	DISTRIB_RELEASE=${DISTRIB_RELEASE}
	EOS
}
