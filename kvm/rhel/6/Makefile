DISTRO_NAMES=centos sl
DISTRO_VERS=6 6.0 6.1 6.2 6.3
VMBUILDER=./vmbuilder.sh

all: build

build: $(DISTRO_NAMES)

centos:
	for distro_ver in $(DISTRO_VERS); do $(VMBUILDER) --distro-name=$@ --distro-ver=$${distro_ver} --execscript=./examples/execscript.sh.example ; done

sl:
	for distro_ver in $(DISTRO_VERS); do $(VMBUILDER) --distro-name=$@ --distro-ver=$${distro_ver} --execscript=./examples/execscript.sh.example ; done

.PHONY: build clean centos sl
