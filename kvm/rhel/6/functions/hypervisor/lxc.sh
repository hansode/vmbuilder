# -*-Shell-script-*-
#
# description:
#  Hypervisor lxc
#
# requires:
#  bash
#
# imports:
#  utils: shlog
#  hypervisor: viftabproc
#

function add_option_hypervisor_lxc() {
  image_format=${image_format:-raw}
  image_file=${image_file:-${name}.${image_format}}
  image_path=${image_path:-${image_file}}

  brname=${brname:-br0}

  mem_size=${mem_size:-1024}
  cpu_num=${cpu_num:-1}

  vif_num=${vif_num:-1}
  viftab=${viftab:-}

  vendor_id=${vendor_id:-52:54:00}
}

## controll lxc process

function start_lxc() {
  echo start_lxc
}

function stop_lxc() {
  echo start_lxc
}
