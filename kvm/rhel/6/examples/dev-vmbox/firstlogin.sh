#!/bin/bash
#
# description:
#  first-login script for vmbuilder.sh
#
# usage:
#  $ vmbuilder.sh --firstlogin=./examples/dev-vmbox/firstlogin.sh
#
# requires:
#  bash
#  git
#
set -e
set -x

## main

git clone git://github.com/hansode/env-bootstrap.git
./env-bootstrap/build-personal-env.sh

git clone git://github.com/hansode/vmbuilder.git work/repos/git/github.com/vmbuilder
