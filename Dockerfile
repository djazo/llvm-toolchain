# Dockerfile to build toolchain for alpine targets x86, armv7 and aarch64

FROM alpine:3.11.5 AS bob

# start by adding basic toolchains for initial build

RUN apk update && \
  apk add --no-cache \
  binutils \
  binutils-gold \
  cmake \
  g++ \
  gcc \
  git \
  libc-dev \
  libedit-dev \
  libffi-dev \
  libxml2-dev \
  linux-headers \
  ninja \
  openssl-dev \
  python3 \
  swig \
  xz-dev \
  z3-dev


# populate sysroots

RUN mkdir -p /var/sysroots && \
  apk --arch x86_64 -X http://dl-cdn.alpinelinux.org/alpine/v3.11/main -U --allow-untrusted --root /var/sysroots/x86_64 --initdb add alpine-base musl-dev libc-dev linux-headers g++ && \
  apk --arch armv7 -X http://dl-cdn.alpinelinux.org/alpine/v3.11/main -U --allow-untrusted --root /var/sysroots/armv7 --initdb add alpine-base musl-dev libc-dev linux-headers g++ && \
  apk --arch aarch64 -X http://dl-cdn.alpinelinux.org/alpine/v3.11/main -U --allow-untrusted --root /var/sysroots/aarch64 --initdb add alpine-base musl-dev libc-dev linux-headers g++

# get the llvm sources

RUN mkdir -p /var/src && \
  git clone --depth 1 --single-branch -b release/10.x https://github.com/llvm/llvm-project.git /var/src/llvm-project

# copy cmake caches

COPY caches/* /tmp/

# build the toolchain

RUN mkdir -p /var/build && \
  cd /var/build && \
  cmake -G Ninja -C /tmp/distribution.cmake -DCMAKE_INSTALL_PREFIX=/opt/toolchain /var/src/llvm-project/llvm && \
  ninja distribution

# install

RUN cd /var/build && \
  ninja install-distribution

FROM alpine:3.11.5

# copy freshly baked toolchain

COPY --from=bob /opt/toolchain /opt/toolchain

ENV PATH="${PATH}:/opt/toolchain/bin"

# add build tools and toolchain dependencies

RUN apk update && apk upgrade --no-cache && \
  runDeps="$( \
  scanelf --needed --nobanner --format '%n#p' --recursive /opt/toolchain \
  | tr ',' '\n' \
  | sort -u \
  | awk 'system("[ -e /opt/toolchain/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  )" && \
  apk add --no-cache \
  cmake \
  make \
  ninja \
  $runDeps
