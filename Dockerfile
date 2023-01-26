# syntax=docker/dockerfile:experimental

FROM node:lts-bullseye-slim AS builder
ARG BUILDARGS
ARG TARGET=x86_64
ARG GMP_TARGET=host
WORKDIR /src
COPY . .

RUN apt update && \
	apt install -y curl build-essential cmake git nasm m4 && \
	git submodule init && git submodule update && \
	./build_gmp.sh $GMP_TARGET

RUN mkdir build_prover && \
	cd build_prover && \
	cmake .. -DTARGET_PLATFORM=$TARGET -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../package && \
	make -j2 && make install

ENTRYPOINT ["/bin/bash"]
