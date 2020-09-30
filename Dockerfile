# Dockerfile to build toolchain for alpine targets x86, armv7 and aarch64
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

# purge asm manuals.

RUN rm -rf /opt/toolchain/share

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

FROM alpine:3.12.0 AS wendy

RUN apk add --no-cache \
	bison \
	build-base \
	ca-certificates \
	curl \
	file \
	flex \
  git \
  texinfo

# set versions

ENV BINUTILS_VERSION 2.35.1
ENV MPFR_VERSION 4.1.0
ENV MPC_VERSION 1.2.0
ENV GMP_VERSION 6.2.0
ENV GCC_VERSION 10.2.0
ENV LIBC_VERSION 2.0.0


RUN mkdir -p /tmp/src/binutils /tmp/src/gcc/mpc /tmp/src/gcc/mpfr /tmp/src/gcc/gmp /tmp/src/avrlibc /tmp/dl /opt/toolchain
# get sources

RUN echo "Downloading sources ..." ; \
	curl -s -L -o /tmp/dl/binutils.tar.bz2 "https://ftpmirror.gnu.org/binutils/binutils-${BINUTILS_VERSION}.tar.bz2" ; \
	curl -s -L -o /tmp/dl/mpfr.tar.bz2 "http://ftp.funet.fi/pub/gnu/ftp.gnu.org/gnu/mpfr/mpfr-${MPFR_VERSION}.tar.bz2" ; \
	curl -s -L -o /tmp/dl/mpc.tar.gz "http://ftp.funet.fi/pub/gnu/ftp.gnu.org/gnu/mpc/mpc-${MPC_VERSION}.tar.gz" ; \
	curl -s -L -o /tmp/dl/gmp.tar.bz2 "http://ftp.funet.fi/pub/gnu/ftp.gnu.org/gnu/gmp/gmp-${GMP_VERSION}.tar.bz2" ; \
	curl -s -L -o /tmp/dl/gcc.tar.xz "http://ftp.funet.fi/pub/gnu/ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz" ; \
	curl -s -L -o /tmp/dl/avrlibc.tar.bz2 "http://download.savannah.gnu.org/releases/avr-libc/avr-libc-${LIBC_VERSION}.tar.bz2"

# extract

RUN echo "Extracting ..." ; \
	tar xjf /tmp/dl/binutils.tar.bz2 --strip-components=1 -C /tmp/src/binutils ; \
	tar xJf /tmp/dl/gcc.tar.xz --strip-components=1 -C /tmp/src/gcc ; \
	tar xjf /tmp/dl/mpfr.tar.bz2 --strip-components=1 -C /tmp/src/gcc/mpfr ; \
	tar xzf /tmp/dl/mpc.tar.gz --strip-components=1 -C /tmp/src/gcc/mpc ; \
	tar xjf /tmp/dl/gmp.tar.bz2 --strip-components=1 -C /tmp/src/gcc/gmp ; \
	tar xjf /tmp/dl/avrlibc.tar.bz2 --strip-components=1 -C /tmp/src/avrlibc ; \
# remove downloads
	rm -rf /tmp/dl

# build binutils

RUN echo "Building binutils ..." ; \
	mkdir -p /tmp/build/binutils ; \
	cd /tmp/build/binutils ; \
	/tmp/src/binutils/configure --prefix=/opt/toolchain --target=avr --disable-nls ; \
	make -s -j$(nproc) ; \
	make install ; \
	cd / ; \
	rm -rf /tmp/src/binutils ; \
	rm -rf /tmp/build/binutils

# populate PATH

ENV PATH="/opt/toolchain/bin:${PATH}"

# build gcc

RUN echo "Building gcc ..." ; \
	mkdir -p /tmp/build/gcc ; \
	cd /tmp/build/gcc ; \
	/tmp/src/gcc/configure --prefix=/opt/toolchain --target=avr --enable-languages=c,c++ --disable-nls --disable-libssp --with-dwarf2 ; \
	make -s -j$(nproc) ; \
	make install ; \
	cd / ; \
	rm -rf /tmp/src/gcc ; \
	rm -rf /tmp/build/gcc

# build avr-libc

RUN echo "Building avr libc ..." ; \
	mkdir -p /tmp/build/avrlibc ; \
	cd /tmp/build/avrlibc ; \
	/tmp/src/avrlibc/configure --prefix=/opt/toolchain --build=x86_64-alpine-linux-musl --host=avr \
	make -s -j$(nproc) ; \
	make install ; \
	cd / ; \
	rm -rf /tmp/src/avrlibc ; \
  rm -rf /tmp/build/avrlibc

FROM alpine:3.12.0

COPY --from=bob /opt/toolchain /opt/toolchain
COPY --from=bob /data/sysroots /opt/sysroots
COPY --from=wendy /opt/avr-toolchain /opt/avr-toolchain

ENV PATH="${PATH}:/opt/toolchain/bin:/opt/avr-toolchain/bin"

RUN apk add --no-cache \
  cmake \
  git \
  make \
  ninja \
  python3 \
  $(scanelf --needed \
  --nobanner --format '%n#p' --recursive /opt/toolchain \
  | tr ',' '\n' \
  | sort -u \
  | awk 'system("[ -e /opt/toolchain/lib/" $1 " ]") == 0 { next } { print "so:" $1 }') && \
  $(scanelf --needed \
  --nobanner --format '%n#p' --recursive /opt/avr-toolchain \
  | tr ',' '\n' \
  | sort -u \
  | awk 'system("[ -e /opt/avr-toolchain/lib/" $1 " ]") == 0 { next } { print "so:" $1 }') && \
  mkdir -p /opt/toolchain/etc /opt/avr-toolchain/etc &&\
  echo "/opt/avr-toolchain/lib" >/opt/avr-toolchain/etc/ld-musl-x86_64.path && \
  echo "/opt/toolchain/lib" >/opt/toolchain/etc/ld-musl-x86_64.path

LABEL com.embeddedreality.image.maintainer="arto.kitula@gmail.com" \
  com.embeddedreality.image.title="llvm-toolchain" \
  com.embeddedreality.image.version="12git" \
  com.embeddedreality.image.description="llvm-toolchain with alpine sysroots+avr"
