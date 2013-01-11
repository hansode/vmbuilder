#!/bin/bash
#
# usage:
#  $ vmbuilder \
#    --execscript=./examples/virtualbox-box/execscript.sh \
#    --addpkg make --addpkg kernel-devel --addpkg gcc --addpkg perl
#
# requires:
#  bash
#  chroot
#
# imports:
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

#### virtualbox
configure_virtualbox ${chroot_dir}

#### vargrant
cat <<'EOS' | chroot ${chroot_dir} bash -c "cat | bash"
case $(arch) in
i*86)   arch=i686   ;;
x86_64) arch=x86_64 ;;
esac
# Vagrant Downloads
# - http://downloads.vagrantup.com/
rpm -ivh http://files.vagrantup.com/packages/476b19a9e5f499b5d0b9d4aba5c0b16ebe434311/vagrant_${arch}.rpm
EOS
