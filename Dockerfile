# Dockerfile to build toolchain for alpine targets x86, armv7 and aarch64

# first we do raspberry os sysroot
FROM debian:buster-slim AS wendy

RUN set -eux ; apt-get update && apt-get -y install debootstrap ;\
  mkdir /raspberryos ; \
  debootstrap --arch=armhf --variant=minbase --no-check-gpg buster /raspberryos http://archive.raspbian.org/raspbian ; \
  chroot /raspberryos /bin/bash -c "apt-get update && apt-get -y install symlinks gcc g++" ; \
  chroot /raspberryos /bin/bash -c "symlinks -c -r /usr" ; \
  for _f in bin boot dev etc home media mnt opt proc root run sbin srv sys tmp var usr/bin usr/sbin usr/libexec usr/share usr/games usr/local usr/lib/apt usr/lib/bfd-plugins usr/lib/compat-ld usr/lib/cpp usr/lib/dpkg usr/lib/gnupg usr/lib/gnupg2 usr/lib/gold-ld usr/lib/init usr/lib/locale usr/lib/lsb usr/lib/lsb usr/lib/mime usr/lib/os-release usr/lib/sasl2 usr/lib/systemd usr/lib/terminfo usr/lib/tmpfiles.d usr/lib/udev; do \
  rm -rf /raspberryos/$_f ; \
  done

FROM alpine:3.12.0 AS bob

# start by adding basic toolchains for initial build

RUN apk add --no-cache \
  binutils \
  binutils-gold \
  bison \
  cmake \
  curl \
  flex \
  g++ \
  gcc \
  git \
  libc-dev \
  libedit-dev \
  libffi-dev \
  libxml2-dev \
  linux-headers \
  make \
  ninja \
  openssl-dev \
  patch \
  python3 \
  swig \
  texinfo \
  xz-dev \
  z3-dev


# populate sysroots


RUN mkdir -p /data/sysroots && \
  apk --arch x86_64 -X http://dl-cdn.alpinelinux.org/alpine/v3.11/main -U --allow-untrusted --root /data/sysroots/x86_64 --initdb add alpine-base musl-dev libc-dev linux-headers g++ && \
  apk --arch armv7 -X http://dl-cdn.alpinelinux.org/alpine/v3.11/main -U --allow-untrusted --root /data/sysroots/armv7 --initdb add alpine-base musl-dev libc-dev linux-headers g++ && \
  apk --arch aarch64 -X http://dl-cdn.alpinelinux.org/alpine/v3.11/main -U --allow-untrusted --root /data/sysroots/aarch64 --initdb add alpine-base musl-dev libc-dev linux-headers g++

COPY --from=wendy /raspberryos /data/sysroots/raspberryos

# purge alpine sysroots

RUN for _g in x86_64 armv7 aarch64 ; do \
  for _f in bin dev etc home media mnt opt proc root run sbin srv sys tmp var usr/bin usr/sbin usr/libexec usr/share usr/$_g*; do \
  rm -rf /data/sysroots/$_g/$_f ; \
  done ; \
  done


# binutils for assembler

ENV BINUTILS_VERSION 2.35

RUN mkdir -p /data/src/binutils ; \
  curl -s -L -o /tmp/binutils.tar.bz2 "https://ftpmirror.gnu.org/binutils/binutils-${BINUTILS_VERSION}.tar.bz2" ; \
  tar xjf /tmp/binutils.tar.bz2 --strip-components=1 -C /data/src/binutils

RUN mkdir -p /data/build-binutils-aarch64 ; \
  cd /data/build-binutils-aarch64 ; \
  /data/src/binutils/configure --prefix=/opt/toolchain --target=aarch64-alpine-linux-musl --disable-nls --disable-multilib ; \
  make -j$(nproc) all-gas; \
  make install-gas

RUN mkdir -p /data/build-binutils-armv7 ; \
  cd /data/build-binutils-armv7 ; \
  /data/src/binutils/configure --prefix=/opt/toolchain --target=armv7-alpine-linux-musl --disable-nls --disable-multilib ; \
  make -j$(nproc) all-gas; \
  make install-gas

RUN mkdir -p /data/build-binutils-x86_64 ; \
  cd /data/build-binutils-x86_64 ; \
  /data/src/binutils/configure --prefix=/opt/toolchain --target=x86_64-alpine-linux-musl --disable-nls --disable-multilib ; \
  make -j$(nproc) all-gas; \
  make install-gas

RUN mkdir -p /data/build-binutils-arm ; \
  cd /data/build-binutils-arm ; \
  /data/src/binutils/configure --prefix=/opt/toolchain --target=arm-linux-gnueabihf --disable-nls --disable-multilib ; \
  make -j$(nproc) all-gas; \
  make install-gas

# get the llvm sources (git )

RUN mkdir -p /data/caches && \
  mkdir -p /data/src && \
  cd /data/src && \
  git clone --depth 1 https://github.com/llvm/llvm-project.git

# copy cmake caches and patches

COPY caches/* /tmp/
COPY patches/* /tmp/

# patch!

RUN cd /data/src/llvm-project && \
  patch -p1 </tmp/alpine.patch

# build the toolchain

ENV PATH="${PATH}:/opt/toolchain/bin"

RUN mkdir -p /data/build && \
  cd /data/build && \
  cmake -G Ninja -C/tmp/embedded.cmake -DCMAKE_INSTALL_PREFIX=/opt/toolchain /data/src/llvm-project/llvm && \
  ninja stage2-distribution

# install

RUN cd /data/build && \
  ninja stage2-install-distribution

FROM alpine:3.12.0

COPY --from=bob /opt/toolchain /opt/toolchain
COPY --from=bob /data/sysroots /opt/sysroots

ENV PATH="${PATH}:/opt/toolchain/bin"

RUN apk add --no-cache \
  cmake \
  git \
  libedit \
  libffi \
  libxml2 \
  make \
  ninja \
  openssl \
  xz-libs \
  z3 && \
  mkdir -p /opt/toolchain/etc &&\
  echo "/opt/toolchain/lib" >/opt/toolchain/etc/ld-musl-x86_64.path

LABEL com.embeddedreality.image.maintainer="arto.kitula@gmail.com" \
  com.embeddedreality.image.title="llvm-toolchain" \
  com.embeddedreality.image.version="12git" \
  com.embeddedreality.image.description="llvm-toolchain with alpine sysroots"
