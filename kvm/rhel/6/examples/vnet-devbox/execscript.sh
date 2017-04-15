#!/bin/bash
#
# description:
#  execscript for vmbuilder.sh
#
# usage:
#  $ vmbuilder.sh --execscript=./examples/vnet-devbox/execscript.sh
#
# requires:
#  bash
#  cat, tee, chroot
#
# imports:
#  utils: run_in_target
#  distro: configure_openvz, detect_distro, create_initial_user
#
set -x
set -e

### read-only variables

readonly abs_dirname=$(cd ${BASH_SOURCE[0]%/*} && pwd)

### include files

. ${abs_dirname}/../../functions/utils.sh
. ${abs_dirname}/../../functions/distro.sh

### private variables

declare chroot_dir=$1

### main

echo "doing execscript.sh: ${chroot_dir}"

#### unix account

eval $(detect_distro ${chroot_dir})
devel_user=centos

# 2. add ${devel_user} as a new unix user

create_initial_user ${chroot_dir}
update_user_password ${chroot_dir} ${devel_user} ${devel_user}

#### Set up Axsh 3rd party repo

run_in_target ${chroot_dir} \
  curl -o /etc/yum.repos.d/wakame-vdc.repo \
  -R https://raw.github.com/axsh/wakame-vdc/master/rpmbuild/wakame-vdc.repo

#### Enable the epel repository

run_in_target ${chroot_dir} \
  "yes | rpm -ivh http://dlc.wakame.axsh.jp.s3-website-us-east-1.amazonaws.com/epel-release"

#### Install VNet dependencies

run_in_target ${chroot_dir} \
  yum -y install wakame-vdc-ruby redis mysql-server make git gcc gcc-c++ \
  zlib-devel openssl-devel zeromq-devel mysql-devel sqlite-devel libpcap-devel \
  upstart

#### Install openvswitch separately because it's not in the 3rd party repo atm

run_in_target ${chroot_dir} \
  rpm -ivh \
  http://dlc.wakame.axsh.jp/packages/3rd/rhel/6/master/openvswitch-1.10.0.fpm0-1.x86_64.rpm

#### Give ourselves a better bash prompt

cat ${abs_dirname}/bash_prompt >> ${chroot_dir}/etc/bashrc

#### Add Wakame-vdc's ruby to the path

echo "PATH=/opt/axsh/wakame-vdc/ruby/bin:$PATH" >> ${chroot_dir}/etc/bashrc
