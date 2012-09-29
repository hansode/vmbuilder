#!/bin/bash
#
# requires:
#  bash
#  tr, dirname, pwd
#  sed, head
#  arch, cat
#  mount, umount, MAKEDEV, yum, chkconfig
#  chroot, pwconv
#  mkdir, cp, rm, rsync, find
#  egrep, xargs, printf
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

function build_vers() {
  debug=${debug:-}
  [ -z ${debug} ] || set -x

  distro_arch=${distro_arch:-$(arch)}
  case "${distro_arch}" in
  i*86)   basearch=i386; distro_arch=i686 ;;
  x86_64) basearch=${distro_arch} ;;
  esac

  distro_ver=${distro_ver:-6.3}
  distro_name=${distro_name:-centos}
  root_dev=${root_dev:-/dev/sda1}

  case "${distro_name}" in
  centos)
    distro_short=centos
    distro_snake=CentOS
    baseurl=${baseurl:-http://ftp.riken.go.jp/pub/Linux/centos/${distro_ver}/os/${basearch}}
    case "${distro_ver}" in
    6|6.*)
      gpgkey="${gpgkey:-${baseurl}/RPM-GPG-KEY-${distro_snake}-6}"
      ;;
    esac
    ;;
  sl|scientific|scientificlinux)
    distro_short=sl
    distro_snake="Scientific Linux"
    baseurl=${baseurl:-http://ftp.riken.go.jp/pub/Linux/scientific/${distro_ver}/${basearch}/os}
    case "${distro_ver}" in
    6|6.*)
      gpgkey="${gpgkey:-${baseurl}/RPM-GPG-KEY-sl ${baseurl}/RPM-GPG-KEY-sl6}"
      ;;
    esac
    ;;
  *)
    echo "no mutch distro" >&2
    return 1
    ;;
  esac

  chroot_dir=${chroot_dir:-${abs_dirname}/${distro_short}-${distro_ver}_${distro_arch}}

  keepcache=${keepcache:-0}
  # keepcache should be [ 0 | 1 ]
  case "${keepcache}" in
  [01]) ;;
  *)    keepcache=0 ;;
  esac

  repofile=${abs_dirname}/yum-${distro_short}-${distro_ver}.repo
}

function banner() {
  cat <<-EOS
	--------------------
	distro_arch: ${distro_arch}
	distro_name: ${distro_name} ${distro_snake}
	distro_ver:  ${distro_ver}
	chroot_dir:  ${chroot_dir}
	keepcache:   ${keepcache}
	baseurl:     ${baseurl}
	gpgkey:      ${gpgkey}
	--------------------
	EOS
}

function yorn() {
  [ -n "${batch}" ] && {
    yorn=y
  } || {
    echo -n "OK? [y/n] "
    read yorn
    echo ${yorn}
  }
  case "${yorn}" in
  ""|n|N|no|NO) return 1 ;;
  esac
}

function mkdevdir() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  mkdir ${chroot_dir}/dev
  for i in console null tty1 tty2 tty3 tty4 zero; do
    MAKEDEV -d ${chroot_dir}/dev -x $i
  done
}

function mkprocdir() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  mkdir ${chroot_dir}/proc
}

function mount_proc() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  mount --bind /proc ${chroot_dir}/proc
}

function umount_proc() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  while read mountpoint; do
    printf "[DEBUG] Unmounting %s\n" ${mountpoint}
    umount ${mountpoint}
  done < <(egrep ${chroot_dir}/ /etc/mtab | awk '{print $2}')
}

function mkrepofile() {
  local repofile=$1
  cat <<-EOS > ${repofile}
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
}

function rmrepofile() {
  local repofile=$1
  [[ -a ${repofile} ]] || { echo "file not found: ${repofile}" >&2; return 1; }
  rm -f ${repofile}
}

function installdistro() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }

  local yum_opts="
     -c ${repofile} \
     --disablerepo="\*" \
     --enablerepo="${distro_short}" \
     --installroot=${chroot_dir} \
     -y
  "
  local yum_cmd="yum ${yum_opts}"

  mkrepofile ${repofile}

  ${yum_cmd} groupinstall Core
  ${yum_cmd} install \
             kernel dracut openssh openssh-clients openssh-server rpm yum curl dhclient \
             passwd grub \
             vim-minimal
  ${yum_cmd} erase selinux*

  rmrepofile ${repofile}
}

function configure_mounting() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  cat <<-EOS > ${chroot_dir}/etc/fstab
	${root_dev}             /                       ext4    defaults        1 1
	tmpfs                   /dev/shm                tmpfs   defaults        0 0
	devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
	sysfs                   /sys                    sysfs   defaults        0 0
	proc                    /proc                   proc    defaults        0 0
	EOS
}

function configure_networking() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  cat <<-EOS > ${chroot_dir}/etc/hosts
	127.0.0.1       localhost
	EOS

  cat <<-EOS > ${chroot_dir}/etc/resolv.conf
	nameserver 8.8.8.8
	EOS

  cat <<-EOS > ${chroot_dir}/etc/sysconfig/network
	NETWORKING=yes
	EOS

  cat <<-EOS > ${chroot_dir}/etc/sysconfig/network-scripts/ifcfg-eth0
	DEVICE=eth0
	BOOTPROTO=dhcp
	ONBOOT=yes
	EOS
}

function configure_passwd() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  chroot ${chroot_dir} pwconv
}

function configure_tz() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  cp ${chroot_dir}/usr/share/zoneinfo/Japan ${chroot_dir}/etc/localtime
}

function configure_service() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  while read svc dummy; do
    chroot ${chroot_dir} chkconfig --del ${svc}
  done < <(chroot ${chroot_dir} chkconfig --list | egrep -v :on)
}

function installgrub() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  for grub_distro_name in redhat unknown; do
    grub_src_dir=${chroot_dir}/usr/share/grub/${basearch}-${grub_distro_name}
    [ -d ${grub_src_dir} ] || continue
    rsync -a ${grub_src_dir}/ ${chroot_dir}/boot/grub/
  done
}

function cleanup() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  find   ${chroot_dir}/var/log/ -type f | xargs rm
  rm -rf ${chroot_dir}/tmp/*
}

## task

function task_prep() {
  [ -d ${chroot_dir} ] && { echo "${chroot_dir} already exists." >&2; return 1; } || :
  banner
  yorn

  mkdir -p ${chroot_dir}
}

function task_setup() {
  mkdevdir  ${chroot_dir}
  mkprocdir ${chroot_dir}
}

function task_install() {
  mount_proc ${chroot_dir}

  installdistro        ${chroot_dir}
  configure_mounting   ${chroot_dir}
  configure_networking ${chroot_dir}
  configure_passwd     ${chroot_dir}
  configure_tz         ${chroot_dir}
  configure_service    ${chroot_dir}
  installgrub          ${chroot_dir}
  cleanup              ${chroot_dir}

  umount_proc ${chroot_dir}
}

function task_clean() {
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  rm -rf ${chroot_dir}
}

function task_finish() {
  printf "[INFO] Installed => %s\n" ${chroot_dir}
  printf "[INFO] Complete!\n"
}

function task_trap() {
  [[ -d "${chroot_dir}" ]] || { echo "directory not found: ${chroot_dir}" >&2; return 1; }
  printf "[DEBUG] Caught signal\n"
  umount_proc ${chroot_dir}
  [ -d ${chroot_dir} ] && rm -rf ${chroot_dir}
  [ -f ${repofile} ] && rmrepofile ${repofile}
  printf "[DEBUG] Cleaned up\n"
}

function checkroot() {
  [[ $UID -ne 0 ]] && {
    echo "[ERROR] Must run as root." >&2
    return 1
  } || :
}

### read-only variables

readonly abs_dirname=$(cd $(dirname $0) && pwd)

### include files

. ${abs_dirname}/functions.utils

### prepare

extract_args $*

## main

build_vers
checkroot
cmd="$(echo ${CMD_ARGS} | sed "s, ,\n,g" | head -1)"

trap task_trap 1 2 3 15

case "${cmd}" in
prep)
  task_prep
  ;;
setup)
  task_setup
  ;;
install)
  task_install
  ;;
post)
  task_finish
  ;;
clean)
  task_clean
  ;;
*)
  # %prep
  task_prep
  # %setup
  task_setup
  # %install
  task_install
  # %post
  task_finish
  ;;
esac
