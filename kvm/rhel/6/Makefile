DISTRO_NAMES=centos sl
DISTRO_VERS=6 6.0 6.1 6.2
VMBUILDER=./vmbuilder.sh

all: build

build: $(DISTRO_NAMES)

centos:
	for distro_ver in $(DISTRO_VERS); do sudo $(VMBUILDER) --distro_name=$@ --distro_ver=$${distro_ver} ; done

sl:
	for distro_ver in $(DISTRO_VERS); do sudo $(VMBUILDER) --distro_name=$@ --distro_ver=$${distro_ver} ; done

.PHONY: build clean centos sl
