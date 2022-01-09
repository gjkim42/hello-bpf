.PHONY: default clean build build-intermediate load unload

OUTPUT_DIR := _output

default: build

clean:
	rm -rf ${OUTPUT_DIR}

build:
	mkdir -p ${OUTPUT_DIR}
	clang -O2 -Wall -target bpf -emit-llvm -c xdp-example.c -o ${OUTPUT_DIR}/xdp-example.bc
	llc ${OUTPUT_DIR}/xdp-example.bc -march=bpf -mcpu=probe -filetype=obj -o ${OUTPUT_DIR}/xdp-example.o

build-intermediate:
	mkdir -p ${OUTPUT_DIR}
	clang -O2 -g -S -Wall -target bpf -c xdp-example.c -o ${OUTPUT_DIR}/xdp-example.S
	llvm-mc -triple bpf -filetype=obj -o ${OUTPUT_DIR}/xdp-example.o ${OUTPUT_DIR}/xdp-example.S

load:
	sudo ip link set dev ${DEV} xdp obj ${OUTPUT_DIR}/xdp-example.o

unload:
	sudo ip link set dev ${DEV} xdp off
