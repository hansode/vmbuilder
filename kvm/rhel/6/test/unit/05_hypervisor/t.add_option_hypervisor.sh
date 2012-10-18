#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

### distro

function test_add_option_hypervisor_distro_exists() {
  local distro=
  local old_distro=${distro}
  add_option_hypervisor
  assertNotEquals "${old_distro}" "${distro}"
}

function test_add_option_hypervisor_distro_empty() {
  local distro=
  local old_distro=${distro}
  add_option_hypervisor
  assertNotEquals "${old_distro}" "${distro}"
}

### distro_dir

function test_add_option_hypervisor_distro_dir_exists() {
  local distro_dir=
  local old_distro_dir=${distro_dir}
  add_option_hypervisor
  assertNotEquals "${old_distro_dir}" "${distro_dir}"
}

function test_add_option_hypervisor_distro_dir_empty() {
  local distro_dir=
  local old_distro_dir=${distro_dir}
  add_option_hypervisor
  assertNotEquals "${old_distro_dir}" "${distro_dir}"
}

### max_mount_count

function test_add_option_hypervisor_max_mount_count_exists() {
  local max_mount_count=1
  local old_max_mount_count=${max_mount_count}
  add_option_hypervisor
  assertEquals "${old_max_mount_count}" "${max_mount_count}"
}

function test_add_option_hypervisor_max_mount_count_empty() {
  local max_mount_count=
  local old_max_mount_count=${max_mount_count}
  add_option_hypervisor
  assertNotEquals "${old_max_mount_count}" "${max_mount_count}"
}

### interval_between_check

function test_add_option_hypervisor_max_mount_count_exists() {
  local interval_between_check=1
  local old_interval_between_check=${interval_between_check}
  add_option_hypervisor
  assertEquals "${old_interval_between_check}" "${interval_between_check}"
}

function test_add_option_hypervisor_max_mount_count_empty() {
  local interval_between_check=
  local old_interval_between_check=${interval_between_check}
  add_option_hypervisor
  assertNotEquals "${old_interval_between_check}" "${interval_between_check}"
}

### rootsize

function test_add_option_hypervisor_rootsize_exists() {
  local rootsize=1
  local old_rootsize=${rootsize}
  add_option_hypervisor
  assertEquals "${old_rootsize}" "${rootsize}"
}

function test_add_option_hypervisor_rootsize_empty() {
  local rootsize=
  local old_rootsize=${rootsize}
  add_option_hypervisor
  assertNotEquals "${old_rootsize}" "${rootsize}"
}

### bootsize

function test_add_option_hypervisor_bootsize_exists() {
  local bootsize=1
  local old_bootsize=${bootsize}
  add_option_hypervisor
  assertEquals "${old_bootsize}" "${bootsize}"
}

function test_add_option_hypervisor_bootsize_empty() {
  local bootsize=
  local old_bootsize=${bootsize}
  add_option_hypervisor
  assertNotEquals "${old_bootsize}" "${bootsize}"
}

### optsize

function test_add_option_hypervisor_optsize_exists() {
  local optsize=1
  local old_optsize=${optsize}
  add_option_hypervisor
  assertEquals "${old_optsize}" "${optsize}"
}

function test_add_option_hypervisor_optsize_empty() {
  local optsize=
  local old_optsize=${optsize}
  add_option_hypervisor
  assertNotEquals "${old_optsize}" "${optsize}"
}

### swapsize

function test_add_option_hypervisor_swapsize_exists() {
  local swapsize=1
  local old_swapsize=${swapsize}
  add_option_hypervisor
  assertEquals "${old_swapsize}" "${swapsize}"
}

function test_add_option_hypervisor_swapsize_empty() {
  local swapsize=
  local old_swapsize=${swapsize}
  add_option_hypervisor
  assertNotEquals "${old_swapsize}" "${swapsize}"
}

### homesize

function test_add_option_hypervisor_homesize_exists() {
  local homesize=1
  local old_homesize=${homesize}
  add_option_hypervisor
  assertEquals "${old_homesize}" "${homesize}"
}

function test_add_option_hypervisor_homesize_empty() {
  local homesize=
  local old_homesize=${homesize}
  add_option_hypervisor
  assertNotEquals "${old_homesize}" "${homesize}"
}

### xpart

function test_add_option_hypervisor_xpart_exists() {
  local xpart=1
  local old_xpart=${xpart}
  add_option_hypervisor
  assertEquals "${old_xpart}" "${xpart}"
}

function test_add_option_hypervisor_xpart_empty() {
  local xpart=
  local old_xpart=${xpart}
  add_option_hypervisor
  assertEquals "${old_xpart}" "${xpart}"
}

### execscript

function test_add_option_hypervisor_execscript_exists() {
  local execscript=1
  local old_execscript=${execscript}
  add_option_hypervisor
  assertEquals "${old_execscript}" "${execscript}"
}

function test_add_option_hypervisor_execscript_empty() {
  local execscript=
  local old_execscript=${execscript}
  add_option_hypervisor
  assertEquals "${old_execscript}" "${execscript}"
}

### raw

function test_add_option_hypervisor_raw_exists() {
  local raw=1
  local old_raw=${raw}
  add_option_hypervisor
  assertEquals "${old_raw}" "${raw}"
}

function test_add_option_hypervisor_raw_empty() {
  local raw=
  local old_raw=${raw}
  add_option_hypervisor
  assertNotEquals "${old_raw}" "${raw}"
}

### chroot_dir

function test_add_option_hypervisor_chroot_dir_exists() {
  local chroot_dir=1
  local old_chroot_dir=${chroot_dir}
  add_option_hypervisor
  assertEquals "${old_chroot_dir}" "${chroot_dir}"
}

function test_add_option_hypervisor_chroot_dir_empty() {
  local chroot_dir=
  local old_chroot_dir=${chroot_dir}
  add_option_hypervisor
  assertNotEquals "${old_chroot_dir}" "${chroot_dir}"
}

### ip

function test_add_option_hypervisor_ip_exists() {
  local ip=1
  local old_ip=${ip}
  add_option_hypervisor
  assertEquals "${old_ip}" "${ip}"
}

function test_add_option_hypervisor_ip_empty() {
  local ip=
  local old_ip=${ip}
  add_option_hypervisor
  assertEquals "${old_ip}" "${ip}"
}

### mask

function test_add_option_hypervisor_mask_exists() {
  local mask=1
  local old_mask=${mask}
  add_option_hypervisor
  assertEquals "${old_mask}" "${mask}"
}

function test_add_option_hypervisor_mask_empty() {
  local mask=
  local old_mask=${mask}
  add_option_hypervisor
  assertEquals "${old_mask}" "${mask}"
}

### net

function test_add_option_hypervisor_net_exists() {
  local net=1
  local old_net=${net}
  add_option_hypervisor
  assertEquals "${old_net}" "${net}"
}

function test_add_option_hypervisor_net_empty() {
  local net=
  local old_net=${net}
  add_option_hypervisor
  assertEquals "${old_net}" "${net}"
}

### bcast

function test_add_option_hypervisor_bcast_exists() {
  local bcast=1
  local old_bcast=${bcast}
  add_option_hypervisor
  assertEquals "${old_bcast}" "${bcast}"
}

function test_add_option_hypervisor_bcast_empty() {
  local bcast=
  local old_bcast=${bcast}
  add_option_hypervisor
  assertEquals "${old_bcast}" "${bcast}"
}

### gw

function test_add_option_hypervisor_gw_exists() {
  local gw=1
  local old_gw=${gw}
  add_option_hypervisor
  assertEquals "${old_gw}" "${gw}"
}

function test_add_option_hypervisor_gw_empty() {
  local gw=
  local old_gw=${gw}
  add_option_hypervisor
  assertEquals "${old_gw}" "${gw}"
}

### dns

function test_add_option_hypervisor_dns_exists() {
  local dns=1
  local old_dns=${dns}
  add_option_hypervisor
  assertEquals "${old_dns}" "${dns}"
}

function test_add_option_hypervisor_dns_empty() {
  local dns=
  local old_dns=${dns}
  add_option_hypervisor
  assertEquals "${old_dns}" "${dns}"
}

### hostname

function test_add_option_hypervisor_hostname_exists() {
  local hostname=1
  local old_hostname=${hostname}
  add_option_hypervisor
  assertEquals "${old_hostname}" "${hostname}"
}

function test_add_option_hypervisor_hostname_empty() {
  local hostname=
  local old_hostname=${hostname}
  add_option_hypervisor
  assertEquals "${old_hostname}" "${hostname}"
}


## shunit2

. ${shunit2_file}
