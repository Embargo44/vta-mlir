//C-API dialect registration. Definition in lib/CAPI/Dialects.cpp.

#ifndef VTA_C_DIALECTS_H
#define VTA_C_DIALECTS_H

//mlir-c/IR.h — standard MLIR C API.
#include "mlir-c/IR.h"

#ifdef __cplusplus
extern "C" {
#endif

//Declares the C-API registration function for the VTA dialect.
//Matches MLIR_DEFINE_CAPI_DIALECT_REGISTRATION in lib/CAPI/Dialects.cpp.
//Used by python/VTAExtension.cpp via mlirGetDialectHandle__vta__().
MLIR_DECLARE_CAPI_DIALECT_REGISTRATION(VTA, vta);

#ifdef __cplusplus
}
#endif

#endif // VTA_C_DIALECTS_H