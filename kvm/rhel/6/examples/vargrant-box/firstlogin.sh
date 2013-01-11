#!/bin/bash
#
# description:
#  first-login script for vmbuilder.sh
#
# usage:
#  $ vmbuilder.sh --firstlogin=./examples/vargrant-box/firstlogin.sh
#
# requires:
#  bash
#  git
#
set -e
set -x

## main

/opt/vagrant/bin/vagrant box add lucid32 http://files.vagrantup.com/lucid32.box
/opt/vagrant/bin/vagrant init lucid32
/opt/vagrant/bin/vagrant up
