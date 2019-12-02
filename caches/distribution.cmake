set(PACKAGE_VENDOR EmbeddedReality CACHE STRING "")
set(CMAKE_BUILD_TYPE Release CACHE STRING "")
set(LLVM_TARGETS_TO_BUILD X86;AArch64;ARM CACHE STRING "")
set(LLVM_DEFAULT_TARGET_TRIPLE x86_64-alpine-linux-musl CACHE STRING "")
set(LLVM_ENABLE_PROJECTS clang;clang-tools-extra;lld CACHE STRING "")
set(LLVM_ENABLE_RUNTIMES compiler-rt CACHE STRING "")
set(LLVM_BUILD_LLVM_DYLIB ON CACHE BOOL "")
set(LLVM_LINK_LLVM_DYLIB ON CACHE BOOL "")
set(LLVM_ENABLE_EH ON CACHE BOOL "")
set(LLVM_ENABLE_FFI ON CACHE BOOL "")
set(LLVM_ENABLE_LTO Thin CACHE STRING "")
set(LLVM_ENABLE_PER_TARGET_RUNTIME_DIR ON CACHE BOOL "")
set(LLVM_ENABLE_RTTI ON CACHE BOOL "")
set(LLVM_INCLUDE_DOCS OFF CACHE BOOL "")
set(LLVM_INCLUDE_EXAMPLES OFF CACHE BOOL "")
set(LLVM_INCLUDE_TESTS OFF CACHE BOOL "")
set(LLVM_INSTALL_TOOLCHAIN_ONLY ON CACHE BOOL "")
set(CMAKE_AR /usr/bin/gcc-ar CACHE STRING "")
set(CMAKE_NM /usr/bin/gcc-nm CACHE STRING "")
set(CMAKE_RANLIB /usr/bin/gcc-ranlib CACHE STRING "")
set(CLANG_DEFAULT_LINKER lld CACHE STRING "")
set(CLANG_DEFAULT_OBJCOPY llvm-objcopy CACHE STRING "")
set(CLANG_DEFAULT_RTLIB compiler-rt CACHE STRING "")
set(COMPILER_RT_BUILD_LIBFUZZER OFF CACHE BOOL "")
set(COMPILER_RT_BUILD_SANITIZERS OFF CACHE BOOL "")
set(COMPILER_RT_BUILD_XRAY OFF CACHE BOOL "")
set(COMPILER_RT_USE_BUILTINS_LIBRARY ON CACHE BOOL "")

set(LLVM_BUILTIN_TARGETS aarch64-alpine-linux-musl;armv7-alpine-linux-musleabihf;x86_64-alpine-linux-musl CACHE STRING "")
set(LLVM_RUNTIME_TARGETS aarch64-alpine-linux-musl;armv7-alpine-linux-musleabihf;x86_64-alpine-linux-musl CACHE STRING "")

set(BUILTINS_aarch64-alpine-linux-musl_CMAKE_SYSROOT /var/sysroots/aarch64 CACHE STRING "")
set(BUILTINS_aarch64-alpine-linux-musl_CMAKE_SYSTEM_NAME Linux CACHE STRING "")
set(RUNTIMES_aarch64-alpine-linux-musl_CMAKE_SYSROOT /var/sysroots/aarch64 CACHE STRING "")
set(RUNTIMES_aarch64-alpine-linux-musl_CMAKE_SYSTEM_NAME Linux CACHE STRING "")
set(RUNTIMES_aarch64-alpine-linux-musl_COMPILER_RT_BUILD_SANITIZERS OFF CACHE BOOL "")
set(RUNTIMES_aarch64-alpine-linux-musl_COMPILER_RT_BUILD_XRAY OFF CACHE BOOL "")
set(RUNTIMES_aarch64-alpine-linux-musl_COMPILER_RT_BUILD_LIBFUZZER OFF CACHE BOOL "")

set(BUILTINS_armv7-alpine-linux-musleabihf_CMAKE_SYSROOT /var/sysroots/armv7 CACHE STRING "")
set(BUILTINS_armv7-alpine-linux-musleabihf_CMAKE_SYSTEM_NAME Linux CACHE STRING "")
set(RUNTIMES_armv7-alpine-linux-musleabihf_CMAKE_SYSROOT /var/sysroots/armv7 CACHE STRING "")
set(RUNTIMES_armv7-alpine-linux-musleabihf_CMAKE_SYSTEM_NAME Linux CACHE STRING "")
set(RUNTIMES_armv7-alpine-linux-musleabihf_COMPILER_RT_BUILD_SANITIZERS OFF CACHE BOOL "")
set(RUNTIMES_armv7-alpine-linux-musleabihf_COMPILER_RT_BUILD_XRAY OFF CACHE BOOL "")
set(RUNTIMES_armv7-alpine-linux-musleabihf_COMPILER_RT_BUILD_LIBFUZZER OFF CACHE BOOL "")

set(BUILTINS_x86_64-alpine-linux-musl_CMAKE_SYSROOT /var/sysroots/x86_64 CACHE STRING "")
set(BUILTINS_x86_64-alpine-linux-musl_CMAKE_SYSTEM_NAME Linux CACHE STRING "")
set(RUNTIMES_x86_64-alpine-linux-musl_CMAKE_SYSROOT /var/sysroots/x86_64 CACHE STRING "")
set(RUNTIMES_x86_64-alpine-linux-musl_CMAKE_SYSTEM_NAME Linux CACHE STRING "")
set(RUNTIMES_x86_64-alpine-linux-musl_COMPILER_RT_BUILD_SANITIZERS OFF CACHE BOOL "")
set(RUNTIMES_x86_64-alpine-linux-musl_COMPILER_RT_BUILD_XRAY OFF CACHE BOOL "")
set(RUNTIMES_x86_64-alpine-linux-musl_COMPILER_RT_BUILD_LIBFUZZER OFF CACHE BOOL "")

set(LLVM_TOOLCHAIN_TOOLS
  dsymutil
  llvm-ar
  llvm-config
  llvm-lib
  llvm-nm
  llvm-objcopy
  llvm-objdump
  llvm-profdata
  llvm-ranlib
  llvm-rc
  llvm-readelf
  llvm-readobj
  llvm-size
  llvm-symbolizer
  CACHE STRING "")

set(LLVM_DISTRIBUTION_COMPONENTS
  clang
  LTO
  LLVM
  clang-cpp
  clang-format
  builtins
  runtimes
  ${LLVM_TOOLCHAIN_TOOLS}
  CACHE STRING "")
