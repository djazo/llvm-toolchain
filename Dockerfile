# Dockerfile to build toolchain for alpine targets x86, armv7 and aarch64

FROM alpine:3.11.6 AS bob

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

# purge sysroot

RUN for _g in x86_64 armv7 aarch64; do \
  for _f in bin dev etc home media mnt opt proc root run sbin srv sys tmp var usr/bin usr/sbin usr/libexec usr/share usr/$_g*; do \
  rm -rf /data/sysroots/$_g/$_f ; \
  done ; \
  done

# get the llvm sources (release)

ENV LLVM_PROJECT_VERSION 10.0.0
RUN mkdir -p /data/caches && \
  mkdir -p /data/src/llvm-project && \
  curl -Ls https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_PROJECT_VERSION}/llvm-project-${LLVM_PROJECT_VERSION}.tar.xz -o /tmp/llvm-project.tar.xz && \
  tar xJf /tmp/llvm-project.tar.xz --strip-components=1 -C /data/src/llvm-project && \
  rm /tmp/llvm-project.tar.xz


# binutils for assembler

ENV BINUTILS_VERSION 2.34

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

# # get the llvm sources (git )

# RUN mkdir -p /data/caches && \
#   mkdir -p /data/src && \
#   cd /data/src && \
#   git clone --depth 1 https://github.com/llvm/llvm-project.git

# copy cmake caches and patches

COPY caches/* /tmp/
COPY patches/* /tmp/

# patch!

RUN cd /data/src/llvm-project && \
  patch -p1 </tmp/alpine10.patch

# build the toolchain

RUN mkdir -p /data/build && \
  cd /data/build && \
  cmake -G Ninja -C/tmp/embedded.cmake -DCMAKE_INSTALL_PREFIX=/opt/toolchain /data/src/llvm-project/llvm && \
  ninja stage2-distribution

# install

RUN cd /data/build && \
  ninja stage2-install-distribution

FROM alpine:3.11.6

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
  com.embeddedreality.image.version="11git" \
  com.embeddedreality.image.description="llvm-toolchain with alpine sysroots"
