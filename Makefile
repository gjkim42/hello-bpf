.PHONY: default build load unload

OUTPUT_DIR := _output

default: build

build:
	clang -O2 -Wall -target bpf -c xdp-example.c -o ${OUTPUT_DIR}/xdp-example.o

load:
	sudo ip link set dev ${DEV} xdp obj ${OUTPUT_DIR}/xdp-example.o

unload:
	sudo ip link set dev ${DEV} xdp off
