add_mlir_dialect_library(MLIRVTA
        VTADialect.cpp
        VTAOps.cpp
        Passes.cpp

        ADDITIONAL_HEADER_DIRS
        ${PROJECT_SOURCE_DIR}/include/VTA

        DEPENDS
        MLIRVTAOpsIncGen
        MLIRVTAPassIncGen

        LINK_LIBS PUBLIC
        MLIRIR
        MLIRInferTypeOpInterface
        MLIRPass
        )