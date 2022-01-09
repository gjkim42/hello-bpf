.PHONY: default clean build build-intermediate load-xdp unload-xdp load-tc unload-tc

OUTPUT_DIR := _output

default: build

clean:
	rm -rf ${OUTPUT_DIR}

build:
	mkdir -p ${OUTPUT_DIR}

	clang -O2 -Wall -target bpf -emit-llvm -c xdp-example.c -o ${OUTPUT_DIR}/xdp-example.bc
	llc ${OUTPUT_DIR}/xdp-example.bc -march=bpf -mcpu=probe -filetype=obj -o ${OUTPUT_DIR}/xdp-example.o

	clang -O2 -Wall -target bpf -emit-llvm -c tc-example.c -o ${OUTPUT_DIR}/tc-example.bc
	llc ${OUTPUT_DIR}/tc-example.bc -march=bpf -mcpu=probe -filetype=obj -o ${OUTPUT_DIR}/tc-example.o

build-intermediate:
	mkdir -p ${OUTPUT_DIR}

	clang -O2 -g -S -Wall -target bpf -c xdp-example.c -o ${OUTPUT_DIR}/xdp-example.S
	llvm-mc -triple bpf -filetype=obj -o ${OUTPUT_DIR}/xdp-example.o ${OUTPUT_DIR}/xdp-example.S

	clang -O2 -g -S -Wall -target bpf -c tc-example.c -o ${OUTPUT_DIR}/tc-example.S
	llvm-mc -triple bpf -filetype=obj -o ${OUTPUT_DIR}/tc-example.o ${OUTPUT_DIR}/tc-example.S

load-xdp:
	sudo ip link set dev ${DEV} xdp obj ${OUTPUT_DIR}/xdp-example.o

unload-xdp:
	sudo ip link set dev ${DEV} xdp off

load-tc:
	sudo tc qdisc add dev ${DEV} clsact
	sudo tc filter add dev ${DEV} ingress bpf da obj ${OUTPUT_DIR}/tc-example.o sec ingress
	sudo tc filter add dev ${DEV} egress bpf da obj ${OUTPUT_DIR}/tc-example.o sec egress

unload-tc:
	sudo tc filter del dev ${DEV} egress
	sudo tc filter del dev ${DEV} ingress
	sudo tc qdisc del dev ${DEV} clsact
