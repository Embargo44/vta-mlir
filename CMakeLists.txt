cmake_minimum_required(VERSION 3.13.4)
project(vta-dialect LANGUAGES CXX C)

set(CMAKE_BUILD_WITH_INSTALL_NAME_DIR ON)

set(CMAKE_CXX_STANDARD 14 CACHE STRING "C++ standard to conform to")

find_package(MLIR REQUIRED CONFIG)

# Path to TVM's vta-hw include directory.
# Override at configure time with -DVTA_HW_INCLUDE=/path/to/... if TVM is
# not at $HOME/tvm.
if(NOT DEFINED VTA_HW_INCLUDE)
    set(VTA_HW_INCLUDE "$ENV{HOME}/tvm/3rdparty/vta-hw/include"
        CACHE PATH "Path to TVM's vta-hw include directory")
endif()

message(STATUS "Using MLIRConfig.cmake in: ${MLIR_DIR}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")

set(LLVM_RUNTIME_OUTPUT_INTDIR ${CMAKE_BINARY_DIR}/bin)
set(LLVM_LIBRARY_OUTPUT_INTDIR ${CMAKE_BINARY_DIR}/lib)
set(MLIR_BINARY_DIR ${CMAKE_BINARY_DIR})

list(APPEND CMAKE_MODULE_PATH "${MLIR_CMAKE_DIR}")
list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
include(TableGen)
include(AddLLVM)
include(AddMLIR)
include(HandleLLVMOptions)

if(MLIR_ENABLE_BINDINGS_PYTHON)
  include(MLIRDetectPythonEnv)
  mlir_configure_python_dev_packages()
endif()

include_directories(${LLVM_INCLUDE_DIRS})
include_directories(${MLIR_INCLUDE_DIRS})
include_directories(${PROJECT_SOURCE_DIR}/include)
include_directories(${PROJECT_BINARY_DIR}/include)
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/tvm/3rdparty/vta-hw/include)
link_directories(${LLVM_BUILD_LIBRARY_DIR})
add_definitions(${LLVM_DEFINITIONS})

add_subdirectory(include)
add_subdirectory(lib)
if(MLIR_ENABLE_BINDINGS_PYTHON)
  message(STATUS "Enabling Python API")
  add_subdirectory(python)
endif()

set(VTA_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(VTA_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})
set(VTA_TOOLS_DIR ${CMAKE_BINARY_DIR}/bin)
set(LLVM_TOOLS_DIR ${LLVM_TOOLS_BINARY_DIR})


add_subdirectory(test)
add_subdirectory(vta-opt)
add_subdirectory(vta-translate)