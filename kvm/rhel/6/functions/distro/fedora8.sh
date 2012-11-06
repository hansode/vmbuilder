# -*-Shell-script-*-
#
# description:
#  Linux Distribution
#
# requires:
#  bash
#
# imports:
#  distro: load_distro_driver
#

function add_option_distro_fedora8() {
  load_distro_driver fedora7
}

# vmbuilder.sh --distro-name=fedora --distro-ver=8 got following errors.
#
# Transaction Test Succeeded
# Running Transaction
#   Erasing    : selinux-policy-targeted-3.0.8-44.fc8.noarch 1/2
# could not open ts_done file: [Errno 2] No such file or directory: '/path/to/vmbuilder/kvm/rhel/6/fedora-8_x86_64/var/lib/yum/transaction-done.2012-11-05.21:13.13'
#   Erasing    : selinux-policy-3.0.8-44.fc8.noarch          2/2
# setsebool:  SELinux is disabled.
# Traceback (most recent call last):
#   File "/usr/lib/python2.6/site-packages/yum/rpmtrans.py", line 407, in callback
#   File "/usr/lib/python2.6/site-packages/yum/rpmtrans.py", line 511, in _unInstStop
#   File "/usr/lib/python2.6/site-packages/yum/rpmtrans.py", line 258, in _scriptout
#   File "/usr/lib/python2.6/site-packages/yum/history.py", line 972, in log_scriptlet_output
#   File "/usr/lib/python2.6/site-packages/yum/sqlutils.py", line 168, in executeSQLQmark
# sqlite3.OperationalError: unable to open database file
# error: python callback <bound method RPMTransaction.callback of <yum.rpmtrans.RPMTransaction instance at 0x25397a0>> failed, aborting!
