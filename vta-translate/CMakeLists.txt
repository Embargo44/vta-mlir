set(LLVM_LINK_COMPONENTS
  Support
  )

include_directories(${VTA_HW_INCLUDE})

get_property(dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)
get_property(translation_libs GLOBAL PROPERTY MLIR_TRANSLATION_LIBS)

add_llvm_executable(vta-translate
  vta-translate.cpp
  )
llvm_update_compile_flags(vta-translate)
target_link_libraries(vta-translate
  PRIVATE
  ${dialect_libs}
  ${translation_libs}
  MLIRIR
  MLIRParser
  MLIRPass
  MLIRSPIRVDialect
  MLIRTranslateLib
  MLIRSupport
  MLIRTransforms
  )

mlir_check_link_libraries(vta-translate)