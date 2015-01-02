# -*-Shell-script-*-
#
# description:
#  Linux Distribution
#
# requires:
#  bash
#  cat, curl
#  rpm, yum, mkdir, arch
#  pwconv, chkconfig, grub, grub2-mkconfig, grub2-set-default
#  cp, rm, ln, touch, rsync
#  find, egrep, grep, sed, xargs
#  mount, umount
#  ls, tail, cp, install
#  file, db_dump, db43_load
#
# imports:
#  utils: checkroot, run_in_target, expand_path, basearch
#  disk: is_dev, mkdevice, mkprocdir, mount_proc, umount_nonroot, xptabinfo, mntpntuuid, get_grub_id, lsdevmap, devmap2lodev
#

## depending on global variables

function add_option_distro() {
  distro_arch=${distro_arch:-$(arch)}
  basearch=$(basearch ${distro_arch})

  case "${basearch}" in
  i386) distro_arch=i686 ;;
  esac

  distro_name=${distro_name}
  distro_ver=${distro_ver}

  keepcache=${keepcache:-0}
  selinux=${selinux:-0}
  sudo_requiretty=${sudo_requiretty}

  distro_name=$(get_normalized_distro_name ${distro_name})

  local driver_name="${distro_name}$(get_distro_major_ver ${distro_ver})"
  case "${driver_name}" in
  rhel7|centos7)
    load_distro_driver ${driver_name}
    ;;
  rhel6|centos6|sl6)
    load_distro_driver ${driver_name}
    ;;
  rhel5|centos5)
    load_distro_driver ${driver_name}
    ;;
  rhel4|centos4)
    load_distro_driver ${driver_name}
    ;;
  fedora[7-9]|fedora1[0-9]|fedora2[0-1])
    load_distro_driver ${driver_name}
    ;;
  *)
    echo "[ERROR] no mutch distro (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
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
  mac=${mac:-}
  hw=${hw:-}
  physdev=${physdev:-}
  onboot=${onboot:-}
  hostname=${hostname:-}

  # settings for the initial user
  devel_user=${devel_user:-}
  devel_pass=${devel_pass:-}
  devel_encpass=${devel_encpass:-}

  rootpass=${rootpass:-}
  rootencpass=${rootencpass:-}

  ssh_key=${ssh_key:-}
  ssh_user_key=${ssh_user_key:-}
  sshd_passauth=${sshd_passauth:-}
  sshd_gssapi_auth=${sshd_gssapi_auth:-}
  sshd_permit_root_login=${sshd_permit_root_login:-}
  sshd_use_dns=${sshd_use_dns:-}

  fstab_type=${fstab_type:-uuid}

  # post_install
  copy=${copy:-}
  copydir=${copydir:-}
  postcopy=${postcopy:-}
  postcopydir=${postcopydir:-}

  execscript=${execscript:-}
  xexecscript=${xexecscript:-}
  postexecscript=${postexecscript:-}
  postxexecscript=${postxexecscript:-}

  firstboot=${firstboot:-}
  everyboot=${everyboot:-}
  firstlogin=${firstlogin:-}
}

function load_distro_driver() {
  local driver_name=$1
  [[ -n "${driver_name}" ]] || { echo "[ERROR] Invalid argument: driver_name:${driver_name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  local distro_driver_path=$(cd ${BASH_SOURCE[0]%/*} && pwd)/distro/${driver_name}.sh
  [[ -f "${distro_driver_path}" ]] || { echo "[ERROR] no such distro driver: ${distro_driver_path} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  . ${distro_driver_path}
  add_option_distro_${driver_name}
}

## distro info

function get_normalized_distro_name() {
  local distro_name=$1
  [[ -n "${distro_name}" ]] || { echo "[ERROR] Invalid argument: distro_name:${distro_name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

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
    echo "[ERROR] no mutch ${BASH_SOURCE[0]##*/}: ${distro_name} (distro:${LINENO})" >&2
    return 1
    ;;
  esac
}

function get_distro_major_ver() {
  local distro_ver=$1
  [[ -n "${distro_ver}" ]] || { echo "[ERROR] Invalid argument: distro_ver:${distro_ver} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  # x.y -> x
  echo ${distro_ver%%.*}
}

function preflight_check_uri() {
  local uri=$1
  [[ -n "${uri}" ]] || { echo "[ERROR] Invalid argument: uri:${uri} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  case "${uri}" in
  http://*)  ;;
  https://*) ;;
  ftp://*)   ;;
  *)
    echo "[ERROR] unknown scheme: ${uri} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
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
 #[[ -n "${baseurl}" ]] || { echo "[ERROR] Invalid argument: baseurl:${baseurl} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
 #preflight_check_uri "${baseurl}" || return 1

  [[ -n "${gpgkey}" ]] || { echo "[ERROR] Invalid argument: gpgkey:${gpgkey} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
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
	keepcache:   1
	baseurl:     ${baseurl}
	gpgkey:      ${gpgkey}
	--------------------
	EOS
}

## chroot distro tree

function build_chroot() {
  add_option_distro
  preflight_check_distro

  local chroot_dir=${1:-${PWD}/${distro_name}-${distro_ver}_${distro_arch}}
  [[ -d "${chroot_dir}" ]] && { echo "[ERROR] ${chroot_dir} already exists (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; } || :

  distroinfo
  # set_defaults
  bootstrap      ${chroot_dir}
  configure_os   ${chroot_dir}
  cleanup_distro ${chroot_dir}
}

function cleanup_distro() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  local varlog=
  while read varlog; do
    cp /dev/null ${varlog}
  done < <(find ${chroot_dir}/var/log/ -type f)
  rm -rf ${chroot_dir}/tmp/*
}

## bootstrap

function trap_distro() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  echo "[DEBUG] trap_distro fired"

  umount_nonroot ${chroot_dir}
  [[ -d "${chroot_dir}" ]] && rm -rf ${chroot_dir}
}

function bootstrap() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] && { echo "[ERROR] ${chroot_dir} already exists (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; } || :
  checkroot || return 1

  trap "trap_distro ${chroot_dir}" ERR

  mkdir -p       ${chroot_dir}
  mkdevice       ${chroot_dir}
  mkprocdir      ${chroot_dir}
  mount_proc     ${chroot_dir}
  run_yum        ${chroot_dir} groupinstall Core
  run_yum        ${chroot_dir} install yum
  umount_nonroot ${chroot_dir}
}

## os configuration

function configure_os() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  mount_proc               ${chroot_dir}
  mount_dev                ${chroot_dir}

  # TODO
  #  should decide where the better place is distro or hypervisor or both.
  #  so far following three functions are defined in distro.
  prevent_daemons_starting ${chroot_dir}
  # moved to hypervisor in order to use cached distro dir
  # always set keepcache=1 at first installation phase
  configure_keepcache      ${chroot_dir} 1

  install_extras           ${chroot_dir}
  umount_nonroot           ${chroot_dir}
}

function configure_acpiphp() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  #Load acpiphp.ko at boot
  printf "[INFO] Adding acpiphp to kernel modules to load at boot\n"
  echo "acpiphp" >> ${chroot_dir}/etc/modules
}

function configure_acpid() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  run_yum                ${chroot_dir} install acpid
  cause_daemons_starting ${chroot_dir} acpid
}

## container

function configure_container() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  # make sure to make device files & directories at post install phase
  mkdevice              ${chroot_dir}

  prevent_udev_starting ${chroot_dir}
  reconfigure_fstab     ${chroot_dir}
  reconfigure_mtab      ${chroot_dir}
}

function configure_openvz() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  install_vzkernel          ${chroot_dir}
  install_vzutils           ${chroot_dir}
  install_menu_lst_vzkernel ${chroot_dir}
  configure_vzconf          ${chroot_dir}
}

function configure_virtualbox() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  install_virtualbox ${chroot_dir}
}

## yum

function repofile() {
  local reponame=$1 baseurl="$2" gpgkey="$3"
  [[ -n "${reponame}" ]] || { echo "[ERROR] Invalid argument: reponame:${reponame} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${baseurl}"  ]] || { echo "[ERROR] Invalid argument: baseurl:${baseurl} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${gpgkey}"   ]] || { echo "[ERROR] Invalid argument: gpgkey:${gpgkey} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  local cachedir=/var/cache/yum
  [[ -z "${basearch}"   ]] || cachedir=${cachedir}/${basearch}
  [[ -z "${distro_ver}" ]] || cachedir=${cachedir}/$(get_distro_major_ver ${distro_ver})

  cat <<-EOS
	[main]
	cachedir=${cachedir}
	keepcache=1
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
  [[ -d "${chroot_dir}"  ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  # install_kernel depends on distro_name.
  [[ -n "${distro_name}" ]] || { echo "[ERROR] Invalid argument: distro_name:${distro_name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  local reponame=${yumrepo:-${distro_name}}
  local tmpdir=${chroot_dir}/tmp
  local repofile=${tmpdir}/yum-${reponame}.repo

  [[ -d "${tmpdir}" ]] || mkdir ${tmpdir}
  repofile ${reponame} "${baseurl}" "${gpgkey}" > ${repofile}

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
  local chroot_dir=$1 keepcache=${2:-${keepcache}}
  [[ -a "${chroot_dir}/etc/yum.conf" ]] || { echo "[ERROR] file not found: ${chroot_dir}/etc/yum.conf (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  case "${keepcache}" in
  0) ;;
  *) keepcache=1 ;;
  esac

  printf "[INFO] Setting /etc/yum.conf: keepcache=%s\n" ${keepcache}
  egrep -q ^keepcache= ${chroot_dir}/etc/yum.conf && {
    sed -i "s,^keepcache=.*,keepcache=${keepcache}," ${chroot_dir}/etc/yum.conf
  } || {
    echo keepcache=${keepcache} >> ${chroot_dir}/etc/yum.conf
  }

  egrep ^keepcache= ${chroot_dir}/etc/yum.conf
}

function preferred_rpmdb_hash_ver() {
  echo ${preferred_rpmdb_hash_ver}
}

function list_rpmdb_file() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  local rpmdb_file=
  while read rpmdb_file; do
    file ${chroot_dir}/var/lib/rpm/${rpmdb_file} | egrep -q "Berkeley DB" || continue
    echo ${chroot_dir}/var/lib/rpm/${rpmdb_file}
  done < <(ls ${chroot_dir}/var/lib/rpm/)
}

function convert_rpmdb_hash() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  local preferred_rpmdb_hash_ver=$(preferred_rpmdb_hash_ver)
  printf "[INFO] Converting rpmdb hash version: %s\n" ${preferred_rpmdb_hash_ver}

  local db_load_cmd=
  case "${preferred_rpmdb_hash_ver}" in
  8)
    # under rhel5
    db_load_cmd=db43_load ;;
  9|*)
    # over rhel6
    return 0 ;;
  esac

  local rpmdb_file=
  while read rpmdb_file; do
    file ${rpmdb_file} | egrep -q "version ${preferred_rpmdb_hash_ver}" && continue
    db_dump ${rpmdb_file} | ${db_load_cmd} ${rpmdb_file}.old.$$
    mv -f ${rpmdb_file}.old.$$ ${rpmdb_file}
  done < <(list_rpmdb_file ${chroot_dir})
}

function clean_packages() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  # make sure to rebuild rpmdb in target.
  # bacause most package is installed via host yum command.
  run_in_target ${chroot_dir} rpm --rebuilddb

  # # yum clean packages
  # > Loaded plugins: product-id, subscription-manager
  # > This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.
  # > There are no enabled repos.
  # > Run "yum repolist all" to see the repos you have.
  # > You can enable repos with yum-config-manager --enable <repo>
}

## other system configuration

function configure_selinux() {
  local chroot_dir=$1 selinux=${2:-0}
  [[ -a "${chroot_dir}/etc/selinux/config" ]] || { echo "[WARN] file not found: ${chroot_dir}/etc/selinux/config (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 0; }

  printf "[INFO] Setting /etc/selinux/config: SELINUX=%s\n" ${selinux}
  case "${selinux}" in
  0)
    sed -i "s/^\(SELINUX=\).*/\1disabled/" ${chroot_dir}/etc/selinux/config
    egrep ^SELINUX= ${chroot_dir}/etc/selinux/config
    ;;
  esac
  cat ${chroot_dir}/etc/selinux/config
}

function config_sshd_config() {
  local sshd_config_path=$1 keyword=$2 value=$3
  [[ -a "${sshd_config_path}" ]] || { echo "[ERROR] file not found: ${sshd_config_path} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${keyword}" ]] || { echo "[ERROR] Invalid argument: keyword:${keyword} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${value}"   ]] || { echo "[ERROR] Invalid argument: value:${value} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  egrep -q -w "^${keyword}" ${sshd_config_path} && {
    # enabled
    sed -i "s,^${keyword}.*,${keyword} ${value},"  ${sshd_config_path}
  } || {
    # commented parameter is "^#keyword value".
    # therefore this case should *not* be included white spaces between # and keyword.
    egrep -q -w "^#${keyword}" ${sshd_config_path} && {
      # disabled
      sed -i "s,^#${keyword}.*,${keyword} ${value}," ${sshd_config_path}
    } || {
      # no match
      echo "${keyword} ${value}" >> ${sshd_config_path}
    }
  }

  egrep -q -w "^${keyword} ${value}" ${sshd_config_path}
}

function configure_sshd_password_authentication() {
  local chroot_dir=$1 passauth=${2:-${sshd_passauth}}
  [[ -a "${chroot_dir}/etc/ssh/sshd_config" ]] || { echo "[WARN] file not found: ${chroot_dir}/etc/ssh/sshd_config (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 0; }

  case "${passauth}" in
  yes|no) ;;
  *) passauth=yes ;;
  esac

  printf "[INFO] Configuring sshd PasswordAuthentication: %s\n" ${passauth}
  config_sshd_config ${chroot_dir}/etc/ssh/sshd_config PasswordAuthentication ${passauth}
}

function configure_sshd_gssapi_authentication() {
  local chroot_dir=$1 gssapi_auth=${2:-${sshd_gssapi_auth}}
  [[ -a "${chroot_dir}/etc/ssh/sshd_config" ]] || { echo "[WARN] file not found: ${chroot_dir}/etc/ssh/sshd_config (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 0; }

  case "${gssapi_auth}" in
  yes|no) ;;
  *) gssapi_auth=yes ;;
  esac

  printf "[INFO] Configuring sshd GSSAPIAuthentication: %s\n" ${gssapi_auth}
  config_sshd_config ${chroot_dir}/etc/ssh/sshd_config GSSAPIAuthentication ${gssapi_auth}
}

function configure_sshd_permit_root_login() {
  local chroot_dir=$1 permit_root_login=${2:-${sshd_permit_root_login}}
  [[ -a "${chroot_dir}/etc/ssh/sshd_config" ]] || { echo "[WARN] file not found: ${chroot_dir}/etc/ssh/sshd_config (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 0; }

  case "${permit_root_login}" in
  yes|no|without-password|forced-commands-only) ;;
  *) permit_root_login=yes ;;
  esac

  printf "[INFO] Configuring sshd PermitRootLogin: %s\n" ${permit_root_login}
  config_sshd_config ${chroot_dir}/etc/ssh/sshd_config PermitRootLogin ${permit_root_login}
}

function configure_sshd_use_dns() {
  local chroot_dir=$1 use_dns=${2:-${sshd_use_dns}}
  [[ -a "${chroot_dir}/etc/ssh/sshd_config" ]] || { echo "[WARN] file not found: ${chroot_dir}/etc/ssh/sshd_config (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 0; }

  case "${use_dns}" in
  yes|no) ;;
  *) use_dns=yes ;;
  esac

  printf "[INFO] Configuring sshd UseDNS: %s\n" ${use_dns}
  config_sshd_config ${chroot_dir}/etc/ssh/sshd_config UseDNS ${use_dns}
}

function check_sudo_requiretty() {
  local sudoers_path=$1
  [[ -a "${sudoers_path}" ]] || { echo "[ERROR] file not found: ${sudoers_path} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  egrep "^Defaults.+requiretty" ${sudoers_path} -q
}

function configure_sudo_requiretty() {
  local chroot_dir=$1 requiretty=${2:-${sudo_requiretty}}
  [[ -a "${chroot_dir}/etc/sudoers" ]] || { echo "[WARN] file not found: ${chroot_dir}/etc/sudoers (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 0; }

  case "${requiretty}" in
  0|1) ;;
  *) requiretty=1 ;;
  esac

  printf "[INFO] Configuring sudo-requiretty: %s\n" ${requiretty}
  case "${requiretty}" in
  0)
    check_sudo_requiretty ${chroot_dir}/etc/sudoers && {
      sed -i "s/^\(^Defaults\s*requiretty\).*/# \1/" ${chroot_dir}/etc/sudoers
    } || :
   ;;
  1)
    check_sudo_requiretty ${chroot_dir}/etc/sudoers || {
      echo "Defaults    requiretty" >> ${chroot_dir}/etc/sudoers
    }
   ;;
  esac
}

function set_timezone() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  printf "[INFO] Setting /etc/localtime\n"
  cp ${chroot_dir}/usr/share/zoneinfo/Japan ${chroot_dir}/etc/localtime
}

function prevent_daemons_starting() {
  local chroot_dir=$1; shift
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  while [[ $# -ne 0 ]]; do
    run_in_target ${chroot_dir} chkconfig $1 off
    shift
  done
}

function cause_daemons_starting() {
  local chroot_dir=$1; shift
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  while [[ $# -ne 0 ]]; do
    run_in_target ${chroot_dir} chkconfig $1 on
    shift
  done
}

function unprevent_daemons_starting() {
  # *obsolete*
  # should use cause_daemons_starting
  cause_daemons_starting $@
}

function prevent_udev_starting() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  # rhel6 does not have /etc/rc.sysinit and /etc/rc.d/rc.sysinit.
  local i=
  for i in ${chroot_dir}/etc/rc.sysinit ${chroot_dir}/etc/rc.d/rc.sysinit; do
    [[ -f ${i} ]] || continue
    sed -i 's,/sbin/start_udev,#\0,' ${i}
  done
}

function prevent_plymouth_starting() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  sed -i 's|\[ "$PROMPT" != no \] && plymouth|[ "$PROMPT" != no ] \&\& [ -n "$PLYMOUTH" ] \&\& plymouth|' \
    ${chroot_dir}/etc/rc.sysinit \
    ${chroot_dir}/etc/rc.d/rc.sysinit

  local upstart_system_jobs="
    plymouth-shutdown.conf
    quit-plymouth.conf
    splash-manager.conf
  "
  for upstart_system_job in ${upstart_system_jobs}; do
    [[ -f ${chroot_dir}/etc/init/${upstart_system_job} ]] && { rm -f ${chroot_dir}/etc/init/${upstart_system_job}; } || :
  done
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
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  printf "[INFO] Overwriting /etc/fstab\n"
  render_fstab ${chroot_dir} ${disk_filename} > ${chroot_dir}/etc/fstab
  cat ${chroot_dir}/etc/fstab
}

function render_fstab() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  render_fstab_ptab ${chroot_dir} ${disk_filename} || return 1
  render_fstab_nonptab
}

function render_fstab_ptab() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  case "${fstab_type:-uuid}" in
  uuid|label) ;;
  *)
    echo "[ERROR] no such fstab_type:${fstab_type} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
    return 1
    ;;
  esac

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

    local dev_path=
    case "${fstab_type:-uuid}" in
    uuid)
      dev_path="UUID=$(mntpntuuid ${disk_filename} ${mountpoint})"
      ;;
    label)
      dev_path="LABEL=${mountpoint}"
      ;;
    esac

    printf "%s %s\t%s\tdefaults\t%s %s\n" ${dev_path} ${mountpath} ${fstype} ${dumpopt} ${fsckopt}
EOS
}

function render_fstab_nonptab() {
  cat <<-_EOS_
	tmpfs                   /dev/shm                tmpfs   defaults        0 0
	devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
	sysfs                   /sys                    sysfs   defaults        0 0
	proc                    /proc                   proc    defaults        0 0
	_EOS_
}

function reconfigure_fstab() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  render_fstab_nonptab > ${chroot_dir}/etc/fstab
  cat ${chroot_dir}/etc/fstab
}

function reconfigure_mtab() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  [[ -f "${chroot_dir}/etc/mtab" ]] && rm -f ${chroot_dir}/etc/mtab || :
  run_in_target ${chroot_dir} ln -fs /proc/mounts /etc/mtab
}

## unix user

function update_passwords() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  printf "[INFO] Updating passwords\n"
  run_in_target ${chroot_dir} pwconv

  # Lock root account only if we didn't set the root password
  if [ -n "${rootpass}" -o -n "${rootencpass}" ]; then
    if [[ -n "${rootencpass}" ]]; then
      update_user_encpassword ${chroot_dir} root ${rootencpass}
    else
      update_user_password ${chroot_dir} root ${rootpass}
    fi
  else
    run_in_target ${chroot_dir} "usermod -L root"
  fi

  # devel_user undefined
  [[ -n "${devel_user}" ]] || return 0

  if [[ -n "${devel_encpass}" ]]; then
    update_user_encpassword ${chroot_dir} ${devel_user} ${devel_encpass}
  else
    update_user_password ${chroot_dir} ${devel_user} ${devel_pass:-${devel_user}}
  fi
}

function create_user_account() {
  local chroot_dir=$1 user_name=$2 gid=$3 uid=$4
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${user_name}"  ]] || { echo "[ERROR] Invalid argument: user_name:${user_name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  printf "[INFO] Creating user: %s\n" ${user_name}

  local user_group=${user_name}
  local user_home=/home/${user_name}

  run_in_target ${chroot_dir} "getent group  ${user_group} >/dev/null || groupadd $([[ -z ${gid} ]] || echo --gid ${gid}) ${user_group}"
  run_in_target ${chroot_dir} "getent passwd ${user_name}  >/dev/null || useradd  $([[ -z ${uid} ]] || echo --uid ${uid}) -g ${user_group} -d ${user_home} -s /bin/bash -m ${user_name}"

  egrep -q ^umask ${chroot_dir}/${user_home}/.bashrc || {
    echo umask 022 >> ${chroot_dir}/${user_home}/.bashrc
  }
}

function update_user_password() {
  local chroot_dir=$1 user_name=$2 user_pass=$3
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${user_name}"  ]] || { echo "[ERROR] Invalid argument: user_name:${user_name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${user_pass}"  ]] || { echo "[ERROR] Invalid argument: user_pass:${user_pass} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  run_in_target ${chroot_dir} "echo ${user_name}:${user_pass} | chpasswd"
}

function update_user_encpassword() {
  local chroot_dir=$1 user_name=$2 user_encpass=$3
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${user_name}"     ]] || { echo "[ERROR] Invalid argument: user_name:${user_name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${user_encpass}"  ]] || { echo "[ERROR] Invalid argument: user_encpass:${user_encpass} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  run_in_target ${chroot_dir} "echo '${user_name}:${user_encpass}' | chpasswd -e"
}

function configure_sudo_sudoers() {
  local chroot_dir=$1 user_name=$2 tag_specs=${3:-"NOPASSWD:"}
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${user_name}"  ]] || { echo "[ERROR] Invalid argument: user_name:${user_name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  #
  # Tag_Spec ::= ('NOPASSWD:' | 'PASSWD:' | 'NOEXEC:' | 'EXEC:' |
  #               'SETENV:' | 'NOSETENV:' | 'LOG_INPUT:' | 'NOLOG_INPUT:' |
  #               'LOG_OUTPUT:' | 'NOLOG_OUTPUT:')
  #
  # **don't forget suffix ":" to tag_specs.**
  #
  egrep ^${user_name} -w ${chroot_dir}/etc/sudoers || { echo "${user_name} ALL=(ALL) ${tag_specs} ALL" >> ${chroot_dir}/etc/sudoers; }
}

function create_initial_user() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  [[ -z "${devel_user}" ]] || {
    create_user_account    ${chroot_dir} ${devel_user}
    configure_sudo_sudoers ${chroot_dir} ${devel_user}
  }

  update_passwords ${chroot_dir}
}

function add_authorized_keys() {
  local user_dir=$1; shift
  local ssh_key_paths="$@"
  [[ -d "${user_dir}"      ]] || { echo "[ERROR] directory not found: ${user_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${ssh_key_paths}" ]] || { echo "[ERROR] Invalid argument: ssh_key_paths:${ssh_key_paths} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  local user_ssh_dir=${user_dir}/.ssh
  local authorized_keys_path=${user_ssh_dir}/authorized_keys

  printf "[INFO] Installing authorized_keys %s\n" ${authorized_keys_path}

  [[ -d "${user_ssh_dir}" ]] || mkdir -m 0700 ${user_ssh_dir}
  # make sure to directory attribute is 0700
  chmod 0700 ${user_ssh_dir}

  # make sure to create file
  [[ -f "${authorized_keys_path}" ]] || : > ${authorized_keys_path}

  local ssh_key_path=
  for ssh_key_path in ${ssh_key_paths}; do
    printf "[DEBUG] Adding authorized_keys %s\n" ${ssh_key_path}
    cat ${ssh_key_path} >> ${authorized_keys_path}
  done

  # make sure to file attribute is 0644
  chmod 0644 ${authorized_keys_path}
}

function install_authorized_keys() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  # root
  [[ -z "${ssh_key}" ]] || {
    add_authorized_keys ${chroot_dir}/root ${ssh_key}
  }

  # devel_user
  [[ -n "${devel_user}" ]] || return 0
  [[ -z "${ssh_user_key}" ]] || {
    add_authorized_keys ${chroot_dir}/home/${devel_user} ${ssh_user_key}
    run_in_target ${chroot_dir} "chown -R ${devel_user}:${devel_user} /home/${devel_user}/.ssh/"
  }
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

  run_yum ${chroot_dir} install openssh openssh-clients openssh-server rpm yum curl dhclient passwd vim-minimal sudo
}

function install_addedpkgs() {
  local chroot_dir=$1

  [[ -z "${addpkg}" ]] || run_yum ${chroot_dir} install ${addpkg}
}

function install_epel() {
  local chroot_dir=$1

  # need to periodically update uri
  # ex) http://ftp.riken.jp/Linux/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
  [[ -z "${epel_uri}" ]] || run_in_target ${chroot_dir} rpm -Uvh ${epel_uri}
}

### openvz kernel

function install_vzkernel() {
  local chroot_dir=$1

  [[ -f ${chroot_dir}/etc/yum.repos.d/openvz.repo ]] || {
    curl -f http://download.openvz.org/openvz.repo -o ${chroot_dir}/etc/yum.repos.d/openvz.repo
  }

  run_in_target ${chroot_dir} yum install -y vzkernel
  verify_kernel_installation ${chroot_dir}
}

function install_vzutils() {
  local chroot_dir=$1

  run_in_target ${chroot_dir} yum install -y vzctl vzquota
}

function configure_vzconf() {
  local chroot_dir=$1

  [[ -f ${chroot_dir}/etc/vz/vz.conf ]] || return 0

  local iptables_modules="
   ipt_REJECT ipt_tos ipt_limit ipt_multiport iptable_filter iptable_mangle ipt_TCPMSS ipt_tcpmss ipt_ttl ipt_length
   ipt_recent ipt_owner ipt_REDIRECT ipt_TOS ipt_LOG ip_conntrack ipt_state iptable_nat ip_nat_ftp
  "
  sed -i "s,^IPTABLES=.*,IPTABLES=\"$(echo ${iptables_modules})\"," ${chroot_dir}/etc/vz/vz.conf
}


### virtualbox

function install_virtualbox() {
  local chroot_dir=$1

  [[ -f ${chroot_dir}/etc/yum.repos.d/virtualbox.repo ]] || {
    curl -f http://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -o ${chroot_dir}/etc/yum.repos.d/virtualbox.repo
  }

  # TODO
  #
  # 1. should run "/etc/init.d/vboxdrv setup" in order to build VirtualBox kernel module after booting system
  #    ex) --firstboot [filename]
  #    --------------------------------------------------
  #    #!/bin/bash
  #
  #    /etc/init.d/vboxdrv setup
  #    reboot
  #    --------------------------------------------------
  #
  # 2. should install packages though "/etc/init.d/vboxdrv setup" depends on make kernel-devel gcc perl
  #    ex) --addpkg [name] ...
  #        --addpkg make --addpkg kernel-devel --addpkg gcc --addpkg perl
  #
  run_yum ${chroot_dir} install make kernel-devel gcc perl
  run_in_target ${chroot_dir} yum install -y VirtualBox-4.2
}

## kernel configuration

function preferred_initrd() {
  echo ${preferred_initrd:-initramfs}
}

function verify_kernel_installation() {
  local chroot_dir=$1

  ls ${chroot_dir}/boot/vmlinuz-*             || { echo "[ERROR] vmlinuz not found (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  ls ${chroot_dir}/boot/$(preferred_initrd)-* || { echo "[ERROR] $(preferred_initrd) not found (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
}

## grub configuration

function preferred_grub() {
  echo ${preferred_grub:-grub}
}

function install_grub() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  local grub_distro_name=
  for grub_distro_name in redhat unknown; do
    grub_src_dir=${chroot_dir}/usr/share/grub/${basearch}-${grub_distro_name}
    [[ -d "${grub_src_dir}" ]] || continue
    rsync -a ${grub_src_dir}/ ${chroot_dir}/boot/grub/
  done
}

function install_grub2() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  # fedora >= 16 should be used not grub but grub2
  run_yum ${chroot_dir} install grub2
}

## bootloader configuration

### vanilla kernel

function install_bootloader_cleanup() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
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
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  checkroot || return 1

  local root_dev="hd$(get_grub_id)"
  local tmpdir=/tmp/vmbuilder-grub

  mkdir -p ${chroot_dir}/${tmpdir}

  is_dev ${disk_filename} || {
    local new_filename=${tmpdir}/${disk_filename##*/}
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
    # got errors on RHEL7
    #grub_cmd="grub2-bios-setup ${target_device}"
    # => grub2-bios-setup: error: cannot stat `/boot/grub2/boot.img': No such file or directory.
    #grub_cmd="grub2-bios-setup --boot-image=/boot/grub2/i386-pc/boot.img --core-image=/boot/grub2/i386-pc/core.img ${target_device}"
    # => grub2-bios-setup: error: cannot stat `/boot/grub2//boot/grub2/i386-pc/boot.img': No such file or directory.
    grub_cmd="grub2-bios-setup --boot-image=i386-pc/boot.img --core-image=i386-pc/core.img ${target_device}"

    install_grub2 ${chroot_dir}
    # > grub2-install: error: /usr/lib/grub/x86_64-efi/modinfo.sh doesn't exist. Please specify --target or --directory.
    # if not --target=i386-pc used, an efi based host gets an above error.
    # --target=i386-pc uses not efi but bios.
    run_in_target ${chroot_dir} grub2-install ${target_device} --target=i386-pc
    # => Installation finished. No error reported.
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
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  case "$(preferred_grub)" in
  grub)  install_menu_lst_grub  ${chroot_dir} ${disk_filename} ;;
  grub2) install_menu_lst_grub2 ${chroot_dir} ${disk_filename} ;;
  esac
}

function install_menu_lst_grub() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  printf "[INFO] Generating /boot/grub/grub.conf\n"

  local bootdir_path=/boot
  xptabinfo | egrep -q /boot && {
    bootdir_path=
  }

  local grub_id=$(get_grub_id)

  local dev_path=
  case "${fstab_type:-uuid}" in
  uuid)
    dev_path="UUID=$(mntpntuuid ${disk_filename} root)"
    ;;
  label)
    dev_path="LABEL=root"
    ;;
  *)
    echo "[ERROR] no such fstab_type:${fstab_type} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
    return 1
    ;;
  esac

  cat <<-_EOS_ > ${chroot_dir}/boot/grub/grub.conf
	default=0
	timeout=5
	splashimage=(hd${grub_id},0)${bootdir_path}/grub/splash.xpm.gz
	hiddenmenu
	title ${distro} ($(cd ${chroot_dir}/boot && ls vmlinuz-* | tail -1 | sed 's,^vmlinuz-,,'))
	        root (hd${grub_id},0)
	        kernel ${bootdir_path}/$(cd ${chroot_dir}/boot && ls vmlinuz-* | tail -1) ro root=${dev_path} rd_NO_LUKS rd_NO_LVM LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM selinux=${selinux:-0}
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
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  printf "[INFO] Generating /boot/grub2/grub.cfg\n"

  cat <<-'EOS' > ${chroot_dir}/etc/default/grub
	GRUB_TIMEOUT=5
	GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
	GRUB_DEFAULT=saved
	GRUB_DISABLE_SUBMENU=true
	GRUB_TERMINAL_OUTPUT="console"
	GRUB_CMDLINE_LINUX="vconsole.keymap=us crashkernel=auto vconsole.font=latarcyrheb-sun16"
	GRUB_DISABLE_RECOVERY="true"
	GRUB_DISABLE_OS_PROBER=true
	EOS

  run_in_target ${chroot_dir} grub2-mkconfig -o /boot/grub2/grub.cfg
  run_in_target ${chroot_dir} grub2-set-default 0

  mangle_grub_menu_lst_grub2 ${chroot_dir} ${disk_filename}

  cat ${chroot_dir}/boot/grub2/grub.cfg
}

function mangle_grub_menu_lst_grub2() {
  local chroot_dir=$1 disk_filename=$2
  [[ -d "${chroot_dir}"    ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -a "${disk_filename}" ]] || { echo "[ERROR] file not found: ${disk_filename} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

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

  local dev_path="UUID=$(mntpntuuid ${disk_filename} root)"
  sed -i "s,/boot,${bootdir_path}," ${chroot_dir}/boot/grub2/grub.cfg
  sed -i "s,root=/[^ ]*,root=${dev_path}," ${chroot_dir}/boot/grub2/grub.cfg

  # show booting progress
  sed -i "s,quiet rhgb,," ${chroot_dir}/boot/grub2/grub.cfg
}

### openvz kernel

function vzkernel_version() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  run_in_target ${chroot_dir} rpm -q --qf '%{Version}-%{Release}' vzkernel
}

function install_menu_lst_vzkernel() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}"                     ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -a "${chroot_dir}/etc/fstab"           ]] || { echo "[WARN] file not found: ${chroot_dir}/etc/fstab (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 0; }
  [[ -a "${chroot_dir}/boot/grub/grub.conf" ]] || { echo "[ERROR] file not found: ${chroot_dir}/boot/grub/grub.conf (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  local version=$(vzkernel_version ${chroot_dir})
  [[ -n "${version}" ]] || { echo "[ERROR] vzkernel not found (${BASH_SOURCE[0]##*/}:${LINENO})" &2; return 1; }

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

function render_resolv_conf() {
  local dnssv=
  for dnssv in ${dns:-8.8.8.8}; do
    cat <<-EOS
	nameserver ${dnssv}
	EOS
  done
}

function install_resolv_conf() {
  local chroot_dir=$1

  printf "[INFO] Generating /etc/resolv.conf\n"
  render_resolv_conf | tee ${chroot_dir}/etc/resolv.conf
}

function configure_networking() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  cat <<-EOS > ${chroot_dir}/etc/sysconfig/network
	NETWORKING=yes
	EOS
  config_host_and_domainname ${chroot_dir}
  install_resolv_conf        ${chroot_dir}
  config_interfaces          ${chroot_dir}
  config_routing             ${chroot_dir}

  config_udev_persistent_net           ${chroot_dir}
  config_udev_persistent_net_generator ${chroot_dir}
}

function config_udev_persistent_net() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  local udev_70_persistent_net_path=${chroot_dir}/etc/udev/rules.d/70-persistent-net.rules
  printf "[INFO] Unsetting udev 70-persistent-net.rules\n"
  [[ -a "${udev_70_persistent_net_path}" ]] && rm -f ${udev_70_persistent_net_path} || :
  ln -s /dev/null ${udev_70_persistent_net_path}
}

function config_udev_persistent_net_generator() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  # Over rhel version 6 has the following file.
  [[ -a "${chroot_dir}/lib/udev/rules.d/75-persistent-net-generator.rules" ]] || { echo "[WARN] file not found: ${chroot_dir}/lib/udev/rules.d/75-persistent-net-generator.rules (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 0; }

  # append virtual interface ignore rules to 75-persistent-net-generator.rules.
  # * udev creates persistent network rule for KVM virtual interface: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=638159
  # * udev: Additional VMware MAC ranges for 75-persistent-net-generator.rules: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=637571
  printf "[INFO] Configuring udev: 75-persistent-net-generator rule\n"
  sed -i -e '/^ENV{MATCHADDR}=="00:00:00:00:00:00", ENV{MATCHADDR}=""/a \
# and KVM, Hyper-V and VMWare virtual interfaces\
ENV{MATCHADDR}=="?[2367abef]:*",       ENV{MATCHADDR}=""\
ENV{MATCHADDR}=="00:00:00:00:00:00",   ENV{MATCHADDR}=""\
ENV{MATCHADDR}=="00:05::69:*|00:0c:29:*|00:50:56:*|00:1C:14:*", ENV{MATCHADDR}=""\
ENV{MATCHADDR}=="00:15:5d:*",          ENV{MATCHADDR}=""\
ENV{MATCHADDR}=="52:54:00:*|54:52:00:*", ENV{MATCHADDR}=""\
' ${chroot_dir}/lib/udev/rules.d/75-persistent-net-generator.rules
}

function config_host_and_domainname() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

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

    case "${hostname}" in
    localhost) ;;
            *) echo 127.0.0.1 ${hostname} >> ${chroot_dir}/etc/hosts ;;
    esac

    cat ${chroot_dir}/etc/hosts
  }
}

function configure_vlan_conf() {
  local chroot_dir=${1}
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  local line=

  # TODO: enable to select "VLAN_NAME_TYPE"
  while read line; do
    egrep -w "^${line}" ${chroot_dir}/etc/sysconfig/network -q || {
      echo "${line}" >> ${chroot_dir}/etc/sysconfig/network
    }
  done < <(cat <<-EOS
	VLAN=yes
	VLAN_NAME_TYPE=VLAN_PLUS_VID_NO_PAD
	EOS
  )
}

function configure_bonding_conf() {
  local chroot_dir=${1} ifname=${2}
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${ifname}"     ]] || { echo "[ERROR] Invalid argument: ifname:${ifname} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  local line=

  if ! [[ -f ${chroot_dir}/etc/modprobe.d/bonding.conf ]]; then
    : > ${chroot_dir}/etc/modprobe.d/bonding.conf
  fi

  while read line; do
    egrep -w "^${line}" ${chroot_dir}/etc/modprobe.d/bonding.conf -q || {
      echo "${line}" >> ${chroot_dir}/etc/modprobe.d/bonding.conf
    }
  done < <(cat <<-EOS
	alias ${ifname} bonding
	EOS
  )
}

function configure_serial_console() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  printf "[INFO] Configuring console\n"

  (
    eval "$(detect_distro ${chroot_dir})"
    case "${DISTRIB_RELEASE}" in
    5.*)
      echo "S0:2345:respawn:/sbin/agetty ttyS0 115200 linux" >> ${chroot_dir}/etc/inittab
      ;;
    6.*)
      [[ -f ${chroot_dir}/etc/sysconfig/init ]] && {
        sed -i "s,^ACTIVE_CONSOLES=.*,ACTIVE_CONSOLES=\"/dev/tty[1-6] /dev/ttyS0\"", ${chroot_dir}/etc/sysconfig/init
      } || :
      ;;
    7.*)
      ln -s /usr/lib/systemd/system/getty@.service ${chroot_dir}/etc/systemd/system/getty.target.wants/getty@ttyS0.service
      ;;
    esac
  )

  egrep -w "^ttyS0" ${chroot_dir}/etc/securetty || { echo ttyS0 >>  ${chroot_dir}/etc/securetty; }
}

## nic configuration

function nictabinfo() {
  {
    if [[ -n "${nictab}" && -f "${nictab}" ]]; then
      cat ${nictab}
    else
      # "echo ${dns}" means removing new-line(s).
      cat <<-EOS
	ifname=eth0 ip=${ip} mask=${mask} net=${net} bcast=${bcast} gw=${gw} dns="$(echo ${dns})" mac=${mac} hw=${hw} physdev=${physdev} bootproto=${bootproto} onboot=${onboot} iftype=ethernet
	EOS
    fi
  } | egrep -v '^$|^#'
}

function config_interfaces() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  local line=
  while read line; do
    (
      ifname= ip= mask= net= bcast= gw= dns= mac= hw= physdev= bootproto= onboot= iftype=
      eval ${line}
      install_interface ${chroot_dir} ${ifname} ${iftype}
    )
  done < <(nictabinfo)
}

function install_interface() {
  local chroot_dir=$1 ifname=${2:-eth0} iftype=${3:-ethernet}
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  local ifcfg_path=/etc/sysconfig/network-scripts/ifcfg-${ifname}

  printf "[INFO] Generating %s\n" ${ifcfg_path}

  iftype=$(echo ${iftype} | tr A-Z a-z)
  case ${iftype} in
  ethernet|ovsport|ovsbridge)
    ;;
  vlan)
    configure_vlan_conf ${chroot_dir}
    ;;
  bonding)
    configure_bonding_conf ${chroot_dir} ${ifname}
    ;;
  bridge)
    run_yum ${chroot_dir} install bridge-utils
    ;;
  tap)
    run_yum ${chroot_dir} install tunctl
    ;;
  *)
    echo "[ERROR] no mutch iftype: ${iftype} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
    return 1
    ;;
  esac

  {
    render_interface_${iftype} ${ifname}
    render_interface_network_configuration
  } | egrep -v '^$' > ${chroot_dir}/${ifcfg_path}
  cat ${chroot_dir}/${ifcfg_path}
}

function render_interface_network_configuration() {
  if [[ -z "${ip}" ]]; then
    bootproto=${bootproto:-dhcp}

    if [[ -n "${bridge}" ]]; then
      bootproto=none
    fi

    cat <<-EOS
	BOOTPROTO=${bootproto}
	EOS
  else
    cat <<-EOS
	BOOTPROTO=static
	IPADDR=${ip}
	$([[ -z "${mask}"   ]] || echo "NETMASK=${mask}")
	$([[ -z "${net}"    ]] || echo "NETWORK=${net}")
	$([[ -z "${bcast}"  ]] || echo "BROADCAST=${bcast}")
	$([[ -z "${gw}"     ]] || echo "GATEWAY=${gw}")
	EOS
  fi

  local dnssv= i=1
  for dnssv in ${dns}; do
    cat <<-EOS
	$([[ -z "${dnssv}"  ]] || echo "DNS${i}=${dnssv}")
	EOS
    let i++
  done

  cat <<-EOS
	$([[ -z "${mac}" ]] || echo "MACADDR=${mac}")
	$([[ -z "${hw}"  ]] || echo "HWADDR=${hw}")
	ONBOOT=${onboot:-yes}
	EOS
}

function render_interface_ethernet() {
  local ifname=${1:-eth0}

  cat <<-EOS
	DEVICE=${ifname}
	TYPE=Ethernet
	$([[ -z "${bridge}" ]] || echo "BRIDGE=${bridge}")
	$([[ -z "${master}" ]] || echo "MASTER=${master}")
	$([[ -z "${master}" ]] || echo "SLAVE=yes")
	EOS
}

function render_interface_tap() {
  local ifname=${1:-tap0}

  cat <<-EOS
	DEVICE=${ifname}
	TYPE=Tap
	$([[ -z "${bridge}" ]] || echo "BRIDGE=${bridge}")
	EOS
}

function render_interface_vlan() {
  local ifname=${1:-vlan0}

  cat <<-EOS
	DEVICE=${ifname}
	$([[ -z "${physdev}" ]] || echo "PHYSDEV=${physdev}")
	$([[ -z "${bridge}"  ]] || echo "BRIDGE=${bridge}")
	EOS
}

function render_interface_bonding() {
  local ifname=${1:-bond0}

  cat <<-EOS
	DEVICE=${ifname}
	BONDING_OPTS="${bonding_opts}"
	EOS
}

function render_interface_bridge() {
  local ifname=${1:-br0}

  cat <<-EOS
	DEVICE=${ifname}
	TYPE=Bridge
	EOS
}

function render_interface_ovsport() {
  local ifname=${1:-eth0}

  cat <<-EOS
	DEVICE=${ifname}
	TYPE=OVSPort
	NM_CONTROLLED=no
	DEVICETYPE=ovs
	$([[ -z "${bridge}" ]] || echo "OVS_BRIDGE=${bridge}")
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
	 set-fail-mode  \${DEVICE} secure --
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
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

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
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${ifname}" ]] || { echo "[ERROR] Invalid argument: ifname:${ifname} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  local route_path=/etc/sysconfig/network-scripts/route-${ifname}

  printf "[INFO] Generating %s\n" ${route_path}

  render_routing ${ifname} | egrep -v '^$' >> ${chroot_dir}/${route_path}
  cat ${chroot_dir}/${route_path}
}

function render_routing() {
  local ifname=$1
  [[ -n "${ifname}" ]] || { echo "[ERROR] Invalid argument: ifname:${ifname} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

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
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

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
  # Red Hat Enterprise Linux Everything release 7.0 Beta (Maipo)
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
	DISTRIB_FLAVOR="${DISTRIB_FLAVOR}"
	DISTRIB_ID="${DISTRIB_ID}"
	DISTRIB_RELEASE="${DISTRIB_RELEASE}"
	EOS
}

## post_install

function run_copies() {
  local chroot_dir=$1; shift
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  while [[ $# -ne 0 ]]; do
    run_copy ${chroot_dir} $1
    shift
  done
}

function run_copy() {
  local chroot_dir=$1 copy=$2
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${copy}" ]] || return 0
  [[ -f "${copy}" ]] || { echo "[ERROR] The path to the copy directive is invalid: ${copy}. Make sure you are providing a full path. (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  (
  printf "[INFO] Copying files specified by copy in: %s\n" ${copy}
  cd ${copy%/*}
  while read line; do
    set ${line}
    [[ $# -ge 2 ]] || continue
    local destdir=${chroot_dir}${2%/*}
    [[ -d "${destdir}" ]] || mkdir -p ${destdir}
    local srcpath=${1} dstpath=${chroot_dir}${2}
    # keep symlink
    # $ rsync -aHA ${1} ${chroot_dir}${2} || :
    # don't keep symlink
    # $ cp -LpR ${1} ${chroot_dir}${2}
    local mode=
    (
      # 1. src dst [options]
      # 2. [options]
      shift 2
      # eval [options]
      eval "$@"

      # keep original file mode
      [[ -n "${mode}" ]] || mode=$(stat -c %a ${srcpath})
      install -p --mode ${mode} --owner ${owner:-root} --group ${group:-root} ${srcpath} ${dstpath}
    )
  done < <(egrep -v '^$|^#' ${copy##*/})
  )
}

function xsync_dir() {
  local chroot_dir=$1; shift
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  while [[ $# -ne 0 ]]; do
    sync_dir ${chroot_dir} $1
    shift
  done
}

function sync_dir() {
  local chroot_dir=$1 sync_dir=$2
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -d "${sync_dir}"   ]] || { echo "[ERROR] directory not found: ${sync_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  printf "[INFO] Syncing directory: %s\n" ${sync_dir}
  rsync -aHA ${sync_dir} ${chroot_dir}/
}

function run_execscripts() {
  local chroot_dir=$1; shift
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  while [[ $# -ne 0 ]]; do
    run_execscript ${chroot_dir} $1
    shift
  done
}

function run_execscript() {
  local chroot_dir=$1 execscript=$2
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${execscript}" ]] || return 0
  [[ -x "${execscript}" ]] || { echo "[WARN] cannot execute script: ${execscript} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 0; }

  printf "[INFO] Excecuting script: %s\n" ${execscript}
  [[ -n "${distro_arch}" ]] || add_option_distro

  setarch ${distro_arch} ${execscript} ${chroot_dir} || {
    echo "[ERROR] execscript failed: exitcode=$? (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
    return 1
  }
}

function run_xexecscripts() {
  local chroot_dir=$1; shift
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  while [[ $# -ne 0 ]]; do
    run_xexecscript ${chroot_dir} $1
    shift
  done
}

function run_xexecscript() {
  local chroot_dir=$1 xexecscript=$2
  [[ -d "${chroot_dir}"  ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${xexecscript}" ]] || return 0
  [[ -x "${xexecscript}" ]] || { echo "[WARN] cannot execute script: ${xexecscript} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 0; }

  printf "[INFO] Excecuting script: %s\n" ${xexecscript}
  [[ -n "${distro_arch}" ]] || add_option_distro

  (. ${xexecscript} ${chroot_dir}) || {
    echo "[ERROR] xexecscript failed: exitcode=$? (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
    return 1
  }
}

function install_firstboot() {
  local chroot_dir=$1 firstboot=$2
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${firstboot}"  ]] || return 0
  [[ -f "${firstboot}"  ]] || { echo "[ERROR] The path to the first-boot directive is invalid: ${firstboot}. Make sure you are providing a full path. (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  printf "[DEBUG] Installing firstboot script %s\n" ${firstboot}
  rsync -aL ${firstboot} ${chroot_dir}/root/firstboot.sh
  chmod 0700 ${chroot_dir}/root/firstboot.sh

  mv ${chroot_dir}/etc/rc.d/rc.local ${chroot_dir}/etc/rc.d/rc.local.orig
  cat <<-'EOS' > ${chroot_dir}/etc/rc.d/rc.local
	#!/bin/sh -e
	#execute firstboot.sh only once
	if [ ! -e /root/firstboot_done ]; then
	    if [ -e /root/firstboot.sh ]; then
	        /root/firstboot.sh
	    fi
	    touch /root/firstboot_done
	fi
	touch /var/lock/subsys/local
	EOS
  chmod 755 ${chroot_dir}/etc/rc.d/rc.local
}

function install_everyboot() {
  local chroot_dir=$1 everyboot=$2
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${everyboot}"  ]] || return 0
  [[ -f "${everyboot}"  ]] || { echo "[ERROR] The path to the first-boot directive is invalid: ${everyboot}. Make sure you are providing a full path. (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  printf "[DEBUG] Installing everyboot script %s\n" ${everyboot}
  rsync -aL ${everyboot} ${chroot_dir}/root/everyboot.sh
  chmod 0700 ${chroot_dir}/root/everyboot.sh

  mv ${chroot_dir}/etc/rc.d/rc.local ${chroot_dir}/etc/rc.d/rc.local.orig
  egrep -v "^touch /var/lock/subsys/local" ${chroot_dir}/etc/rc.d/rc.local.orig > ${chroot_dir}/etc/rc.d/rc.local

  cat <<-'EOS' >> ${chroot_dir}/etc/rc.d/rc.local
	if [ -e /root/everyboot.sh ]; then
	    /root/everyboot.sh
	fi
	touch /var/lock/subsys/local
	EOS
  chmod 755 ${chroot_dir}/etc/rc.d/rc.local
}

function install_firstlogin() {
  local chroot_dir=$1 firstlogin=$2
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${firstlogin}" ]] || return 0
  [[ -f "${firstlogin}" ]] || { echo "[ERROR] The path to the first-login directive is invalid: ${firstlogin}. Make sure you are providing a full path. (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  printf "[DEBUG] Installing first login script %s\n" ${firstlogin}
  rsync -aL ${firstlogin} ${chroot_dir}/root/firstlogin.sh
  chmod 0755 ${chroot_dir}/root/firstlogin.sh

  cp ${chroot_dir}/etc/bashrc ${chroot_dir}/etc/bashrc.orig
  cat <<-'EOS' >> ${chroot_dir}/etc/bashrc
	#execute firstlogin.sh only once
	if [ ! -e /root/firstlogin_done ]; then
	    if [ -e /root/firstlogin.sh ]; then
	        /root/firstlogin.sh
	    fi
	    # This part should not be necessary any more
	    # sudo dpkg-reconfigure -p critical console-setup &> /dev/null
	    sudo touch /root/firstlogin_done
	    # MEMO(first-login): should be changed previous attribute?
	    # sudo chmod 0550 ${chroot_dir}/root/
	fi
	EOS
  # MEMO(first-login): should be changed to access first-login script.
  chmod 0711 ${chroot_dir}/root/
}
