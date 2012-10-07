#!/bin/bash
#
# requires:
#  bash
#  tr, dirname, pwd
#  sed, head
#  arch, cat, mkdir, printf
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

function register_options() {
  debug=${debug:-}
  [ -z ${debug} ] || set -x

  distro_arch=${distro_arch:-$(arch)}
  case "${distro_arch}" in
  i*86)   basearch=i386; distro_arch=i686 ;;
  x86_64) basearch=${distro_arch} ;;
  esac

  distro_ver=${distro_ver:-6.3}
  distro_name=${distro_name:-centos}

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

## task

function task_prep() {
  [ -d ${chroot_dir} ] && { echo "${chroot_dir} already exists." >&2; return 1; } || :
  banner
  yorn

  mkdir -p ${chroot_dir}
}

function task_setup() {
  mkdevice  ${chroot_dir}
  mkprocdir ${chroot_dir}
}

function task_install() {
  mount_proc ${chroot_dir}

  installdistro        ${chroot_dir} ${distro_short} ${baseurl} ${gpgkey} ${keepcache}
  install_fstab        ${chroot_dir}
  configure_networking ${chroot_dir}
  configure_passwd     ${chroot_dir}
  set_timezone         ${chroot_dir}
  prevent_daemons_starting ${chroot_dir}
  install_grub         ${chroot_dir}
  cleanup              ${chroot_dir}

  umount_nonroot ${chroot_dir}
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
  umount_nonroot ${chroot_dir}
  [ -d ${chroot_dir} ] && rm -rf ${chroot_dir}
  printf "[DEBUG] Cleaned up\n"
}

### read-only variables

readonly abs_dirname=$(cd $(dirname $0) && pwd)

### include files

. ${abs_dirname}/functions.utils
. ${abs_dirname}/functions.disk
. ${abs_dirname}/functions.distro

### prepare

extract_args $*

## main

register_options
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
