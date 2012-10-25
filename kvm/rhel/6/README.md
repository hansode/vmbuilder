vmbuilder.sh
============

``vmbuilder.sh`` builds virtual machines for CentOS 6.x from the command line.

System Requirements
-------------------

+ RHEL 6.x / CentOS 6.x

Installing vmbuilder.sh
-----------------------

    $ git clone git://github.com/hansode/vmbuilder.git
    $ cd vmbuilder/kvm/rhel/6/

Building virtual machine image
-------------------------------

    # ./vmbuilder.sh

This will create a virtual machine image in a directory.

    # ls <distro_name>-<distro_ver>_<distro_arch>.raw

OPTIONS
-------

### Guest partitioning options

+ --rootsize=SIZE [default: 4096]
+ --swapsize=SIZE [default: 1024]

###  Network related options:

+ --ip=ADDRESS  [default: dhcp]
+ --mask=VALUE  [default: based on ip setting]
+ --net=ADDRESS [default: based on ip setting]
+ --bcast=VALUE [default: based on ip setting]
+ --gw=ADDRESS  [default: based on ip setting (first valid address in the network)]
+ --dns=ADDRESS [default: 8.8.8.8]

### Post install actions:

+ --execscript=SCRIPT

Script will be called with the guest's chroot as first argument, so you can use chroot $1 <cmd> to run code in the virtual machine.

### Distrobution related options:

+ --distro-arch=VALUE [ x86_64 | i686 ]
+ --distro-name=VALUE [ centos | sl ]
+ --distro-ver=VALUE  [ 6 | 6.0 | 6.2 | 6.3 | ... ]
