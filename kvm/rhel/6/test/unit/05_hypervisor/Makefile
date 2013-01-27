all: test

test: kvm lxc null openvz
	for i in ./t.*; do $$i || exit; done

kvm:
	(cd $@ && make)
lxc:
	(cd $@ && make)
null:
	(cd $@ && make)
openvz:
	(cd $@ && make)

.PHONY: kvm lxc null openvz
