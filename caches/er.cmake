set(PACKAGE_VENDOR Embeddedreality CACHE STRING "")

if(NOT APPLE)
  set(CMAKE_AR gcc-ar CACHE STRING "")
  set(CMAKE_AR gcc-ar CACHE STRING "")
  set(CMAKE_NM gcc-nm CACHE STRING "")
  set(CMAKE_RANLIB gcc-ranlib CACHE STRING "")
  set(LLVM_USE_LINKER gold CACHE STRING "")
endif()

set(CMAKE_BUILD_TYPE Release CACHE STRING "")
set(LLVM_INCLUDE_DOCS OFF CACHE BOOL "")
set(LLVM_INCLUDE_EXAMPLES OFF CACHE BOOL "")
set(LLVM_INCLUDE_TESTS OFF CACHE BOOL "")
set(LLVM_INCLUDE_BENCHMARKS OFF CACHE BOOL "")

set(LLVM_TARGETS_TO_BUILD X86;ARM;AArch64;AVR;RISCV CACHE STRING "")
set(LLVM_ENABLE_PROJECTS "clang;clang-tools-extra;lld" CACHE STRING "")
set(LLVM_ENABLE_RUNTIMES "compiler-rt;libunwind;libcxxabi;libcxx" CACHE STRING "")
set(LLVM_LINK_LLVM_DYLIB ON CACHE BOOL "")
set(LLVM_ENABLE_PIC ON CACHE BOOL "")
set(LLVM_ENABLE_RTTI ON CACHE BOOL "")
set(LLVM_ENABLE_EH ON CACHE BOOL "")
set(LLVM_ENABLE_PER_TARGET_RUNTIME_DIR ON CACHE BOOL "")
set(ENABLE_LINKER_BUILD_ID ON CACHE BOOL "")

set(CLANG_DEFAULT_RTLIB compiler-rt CACHE STRING "")
if(NOT APPLE)
  set(CLANG_DEFAULT_LINKER lld CACHE STRING "")
  set(CLANG_DEFAULT_OBJCOPY llvm-objcopy CACHE STRING "")
endif()
set(CLANG_DEFAULT_CXX_STDLIB libc++ CACHE STRING "")
set(COMPILER_RT_DEFAULT_TARGET_ONLY ON CACHE BOOL "")
set(COMPILER_RT_USE_BUILTINS_LIBRARY ON CACHE BOOL "")
if(APPLE)
  set(COMPILER_RT_ENABLE_IOS OFF CACHE BOOL "")
  set(COMPILER_RT_ENABLE_TVOS OFF CACHE BOOL "")
  set(COMPILER_RT_ENAVLE_WATCHOS OFF CACHE BOOL "")
else()
  set(COMPILER_RT_BUILD_LIBFUZZER OFF CACHE BOOL "")
  set(COMPILER_RT_BUILD_SANITIZERS OFF CACHE BOOL "")
  set(COMPILER_RT_BUILD_XRAY OFF CACHE BOOL "")
  set(COMPILER_RT_BUILD_PROFILE OFF CACHE BOOL "")
endif()
set(LIBUNWIND_ENABLE_SHARED OFF CACHE BOOL "")
set(LIBUNWIND_INSTALL_LIBRARY OFF CACHE BOOL "")
set(LIBUNWIND_USE_COMPILER_RT ON CACHE BOOL "")
set(LIBCXXABI_ENABLE_SHARED OFF CACHE BOOL "")
set(LIBCXXABI_ENABLE_STATIC_UNWINDER ON CACHE BOOL "")
set(LIBCXXABI_USE_COMPILER_RT ON CACHE BOOL "")
set(LIBCXXABI_USE_LLVM_UNWINDER ON CACHE BOOL "")
set(LIBCXXABI_INSTALL_LIBRARY OFF CACHE BOOL "")
set(LIBCXX_ABI_VERSION 2 CACHE STRING "")
set(LIBCXX_ENABLE_SHARED OFF CACHE BOOL "")
set(LIBCXX_ENABLE_STATIC_ABI_LIBRARY ON CACHE BOOL "")
# yeah, apple or alpine, you mfs
if(NOT APPLE)
  set(LIBCXX_HAS_MUSL_LIBC ON CACHE BOOL "")
endif()
set(LIBCXX_USE_COMPILER_RT ON CACHE BOOL "")

# if(UNIX)
#   set(BOOTSTRAP_CMAKE_SHARED_LINKER_FLAGS "-ldl -lpthread" CACHE STRING "")
#   set(BOOTSTRAP_CMAKE_MODULE_LINKER_FLAGS "-ldl -lpthread" CACHE STRING "")
#   set(BOOTSTRAP_CMAKE_EXE_LINKER_FLAGS "-ldl -lpthread" CACHE STRING "")
# endif()

set(BOOTSTRAP_LLVM_ENABLE_LTO ON CACHE BOOL "")

if(NOT APPLE)
  set(BOOTSTARP_LLVM_ENABLE_LLD ON CACHE BOOL "")
endif()

set(BOOTSTRAP_LLVM_ENABLE_LIBCXX ON CACHE BOOL "")

set(CLANG_BOOTSTRAP_TARGETS
  check-all
  check-llvm
  check-clang
  check-lld
  llvm-config
  test-suite
  test-depends
  llvm-test-depends
  clang-test-depends
  lld-test-depends
  distribution
  install-distribution
  install-distribution-stripped
  install-distribution-toolchain
  clang CACHE STRING "")

# Setup the bootstrap build.
set(CLANG_ENABLE_BOOTSTRAP ON CACHE BOOL "")
set(CLANG_BOOTSTRAP_EXTRA_DEPS
  builtins
  runtimes
  CACHE STRING "")
set(CLANG_BOOTSTRAP_CMAKE_ARGS
  ${EXTRA_ARGS}
  -C ${CMAKE_CURRENT_LIST_DIR}/er-stage2.cmake
  CACHE STRING "")
