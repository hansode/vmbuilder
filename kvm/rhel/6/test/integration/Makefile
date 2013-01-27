all: test

test: 02_disk 03_mbr 06_vm

02_disk:
	(cd $@ && make)
03_mbr:
	(cd $@ && make)
04_distro:
	(cd $@ && make)
05_hypervisor:
	(cd $@ && make)
06_vm:
	(cd $@ && make)

.PHONY: 02_disk 03_mbr 04_distro 05_hypervisor 06_vm
