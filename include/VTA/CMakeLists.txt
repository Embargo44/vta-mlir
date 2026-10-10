add_mlir_dialect(VTAOps vta)
add_mlir_doc(VTADialect VTADialect VTA/ -gen-dialect-doc)
add_mlir_doc(VTAOps VTAOps VTA/ -gen-op-doc)

set(LLVM_TARGET_DEFINITIONS VTAOps.td)
mlir_tablegen(VTAPasses.h.inc -gen-pass-decls -name VTA)
add_public_tablegen_target(MLIRVTAPassIncGen)
