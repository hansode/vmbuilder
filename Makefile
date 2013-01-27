all:

test:
	(cd kvm/rhel/6/test && make)

.PHONY: test
