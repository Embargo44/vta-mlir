include(AddMLIRPython)

# Specifies that all MLIR packages are co-located under the `mlir_vta`
# top level package (the API has been embedded in a relocatable way).
# TODO: Add an upstream cmake param for this vs having a global here.
add_compile_definitions("MLIR_PYTHON_PACKAGE_PREFIX=mlir_vta.")


################################################################################
# Sources
################################################################################

declare_mlir_python_sources(VTAPythonSources)

declare_mlir_dialect_python_bindings(
  ADD_TO_PARENT VTAPythonSources
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/mlir_vta"
  TD_FILE dialects/VTAOps.td
  SOURCES
    dialects/vta.py
  DIALECT_NAME vta)

declare_mlir_python_extension(VTAPythonSources.Extension
  MODULE_NAME _vtaDialects
  ADD_TO_PARENT VTAPythonSources
  SOURCES
    VTAExtension.cpp
  EMBED_CAPI_LINK_LIBS
    VTACAPI
)

################################################################################
# Common CAPI
################################################################################

add_mlir_python_common_capi_library(VTAPythonCAPI
  INSTALL_COMPONENT VTAPythonModules
  INSTALL_DESTINATION python_packages/vta/mlir_vta/_mlir_libs
  OUTPUT_DIRECTORY "${MLIR_BINARY_DIR}/python_packages/vta/mlir_vta/_mlir_libs"
  RELATIVE_INSTALL_ROOT "../../../.."
  DECLARED_SOURCES
    VTAPythonSources
    # TODO: Remove this in favor of showing fine grained registration once
    # available.
    MLIRPythonExtension.RegisterEverything
    MLIRPythonSources.Core
)

################################################################################
# Instantiation of all Python modules
################################################################################

add_mlir_python_modules(VTAPythonModules
  ROOT_PREFIX "${MLIR_BINARY_DIR}/python_packages/vta/mlir_vta"
  INSTALL_PREFIX "python_packages/vta/mlir_vta"
  DECLARED_SOURCES
    VTAPythonSources
    # TODO: Remove this in favor of showing fine grained registration once
    # available.
    MLIRPythonExtension.RegisterEverything
    MLIRPythonSources
  COMMON_CAPI_LINK_LIBS
    VTAPythonCAPI
  )
