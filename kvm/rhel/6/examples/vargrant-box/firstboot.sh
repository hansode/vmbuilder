#!/bin/bash
#
# description:
#  first-boot script for vmbuilder.sh
#
# usage:
#  $ vmbuilder.sh --firstboot=./examples/vargrant-box/firstboot.sh
#
# requires:
#  bash
#  /etc/init.d/vboxdrv
#
set -e
set -x

## main

/etc/init.d/vboxdrv setup
reboot
