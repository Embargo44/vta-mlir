//===- VTAInterfaces.td - VTA Dialect Interfaces -----------*- tablegen -*-===//
//
// Defines the interfaces for VTA operations to group them logically.
//
//===----------------------------------------------------------------------===//

#ifndef VTA_INTERFACES
#define VTA_INTERFACES

include "mlir/IR/OpBase.td"

//===----------------------------------------------------------------------===//
// Load Interface (LoadOp, LoadNoOp)
//===----------------------------------------------------------------------===//
def VTA_LoadOpInterface : OpInterface<"LoadOpInterface"> {
  let description = [{
    Interface for VTA load operations.
  }];
  let cppNamespace = "::mlir::vta";
  
  let methods = [
    InterfaceMethod<"Get the raw opcode", "uint8_t", "getOpcode", (ins), [{}], [{ return 0; }]>,
    InterfaceMethod<"Get pop_prev_dep flag", "bool", "getPopPrevDep">,
    InterfaceMethod<"Get pop_next_dep flag", "bool", "getPopNextDep">,
    InterfaceMethod<"Get push_prev_dep flag", "bool", "getPushPrevDep">,
    InterfaceMethod<"Get push_next_dep flag", "bool", "getPushNextDep">,
    InterfaceMethod<"Get memory type", "uint8_t", "getMemoryType">,
    InterfaceMethod<"Get SRAM base", "uint16_t", "getSramBase">,
    InterfaceMethod<"Get DRAM base", "uint32_t", "getDramBase">,
    InterfaceMethod<"Get Y size", "uint16_t", "getYSize">,
    InterfaceMethod<"Get X size", "uint16_t", "getXSize">,
    InterfaceMethod<"Get X stride", "uint16_t", "getXStride">,
    InterfaceMethod<"Get Y pad 0", "uint8_t", "getYPad0">,
    InterfaceMethod<"Get Y pad 1", "uint8_t", "getYPad1">,
    InterfaceMethod<"Get X pad 0", "uint8_t", "getXPad0">,
    InterfaceMethod<"Get X pad 1", "uint8_t", "getXPad1">
  ];
}

//===----------------------------------------------------------------------===//
// Store Interface (StoreOp, StoreNoOp)
//===----------------------------------------------------------------------===//
def VTA_StoreOpInterface : OpInterface<"StoreOpInterface"> {
  let description = [{
    Interface for VTA store operations.
  }];
  let cppNamespace = "::mlir::vta";
  
  let methods = [
    InterfaceMethod<"Get the raw opcode", "uint8_t", "getOpcode", (ins), [{}], [{ return 0; }]>,
    InterfaceMethod<"Get pop_prev_dep flag", "bool", "getPopPrevDep">,
    InterfaceMethod<"Get pop_next_dep flag", "bool", "getPopNextDep">,
    InterfaceMethod<"Get push_prev_dep flag", "bool", "getPushPrevDep">,
    InterfaceMethod<"Get push_next_dep flag", "bool", "getPushNextDep">,
    InterfaceMethod<"Get memory type", "uint8_t", "getMemoryType">,
    InterfaceMethod<"Get SRAM base", "uint16_t", "getSramBase">,
    InterfaceMethod<"Get DRAM base", "uint32_t", "getDramBase">,
    InterfaceMethod<"Get Y size", "uint16_t", "getYSize">,
    InterfaceMethod<"Get X size", "uint16_t", "getXSize">,
    InterfaceMethod<"Get X stride", "uint16_t", "getXStride">,
    InterfaceMethod<"Get Y pad 0", "uint8_t", "getYPad0">,
    InterfaceMethod<"Get Y pad 1", "uint8_t", "getYPad1">,
    InterfaceMethod<"Get X pad 0", "uint8_t", "getXPad0">,
    InterfaceMethod<"Get X pad 1", "uint8_t", "getXPad1">
  ];
}

//===----------------------------------------------------------------------===//
// GEMM Interface (GemmOp)
//===----------------------------------------------------------------------===//
def VTA_GemmOpInterface : OpInterface<"GemmOpInterface"> {
  let description = [{
    Interface for VTA GEMM operations.
  }];
  let cppNamespace = "::mlir::vta";
  
  let methods = [
    InterfaceMethod<"Get the raw opcode", "uint8_t", "getOpcode", (ins), [{}], [{ return 0; }]>,
    InterfaceMethod<"Get pop_prev_dep flag", "bool", "getPopPrevDep">,
    InterfaceMethod<"Get pop_next_dep flag", "bool", "getPopNextDep">,
    InterfaceMethod<"Get push_prev_dep flag", "bool", "getPushPrevDep">,
    InterfaceMethod<"Get push_next_dep flag", "bool", "getPushNextDep">,
    InterfaceMethod<"Get reset_reg flag", "bool", "getResetReg">,
    InterfaceMethod<"Get UOP begin", "uint8_t", "getUopBgn">,
    InterfaceMethod<"Get UOP end", "uint8_t", "getUopEnd">,
    InterfaceMethod<"Get iter_out", "uint16_t", "getIterOut">,
    InterfaceMethod<"Get iter_in", "uint16_t", "getIterIn">,
    InterfaceMethod<"Get dst_factor_out", "uint8_t", "getDstFactorOut">,
    InterfaceMethod<"Get dst_factor_in", "uint8_t", "getDstFactorIn">,
    InterfaceMethod<"Get src_factor_out", "uint8_t", "getSrcFactorOut">,
    InterfaceMethod<"Get src_factor_in", "uint8_t", "getSrcFactorIn">,
    InterfaceMethod<"Get wgt_factor_out", "uint8_t", "getWgtFactorOut">,
    InterfaceMethod<"Get wgt_factor_in", "uint8_t", "getWgtFactorIn">
  ];
}

//===----------------------------------------------------------------------===//
// ALU Interface (AluOp)
//===----------------------------------------------------------------------===//
def VTA_AluOpInterface : OpInterface<"AluOpInterface"> {
  let description = [{
    Interface for VTA ALU operations.
  }];
  let cppNamespace = "::mlir::vta";
  
  let methods = [
    InterfaceMethod<"Get the raw opcode", "uint8_t", "getOpcode", (ins), [{}], [{ return 0; }]>,
    InterfaceMethod<"Get pop_prev_dep flag", "bool", "getPopPrevDep">,
    InterfaceMethod<"Get pop_next_dep flag", "bool", "getPopNextDep">,
    InterfaceMethod<"Get push_prev_dep flag", "bool", "getPushPrevDep">,
    InterfaceMethod<"Get push_next_dep flag", "bool", "getPushNextDep">,
    InterfaceMethod<"Get reset_reg flag", "bool", "getResetReg">,
    InterfaceMethod<"Get UOP begin", "uint8_t", "getUopBgn">,
    InterfaceMethod<"Get UOP end", "uint8_t", "getUopEnd">,
    InterfaceMethod<"Get iter_out", "uint16_t", "getIterOut">,
    InterfaceMethod<"Get iter_in", "uint16_t", "getIterIn">,
    InterfaceMethod<"Get dst_factor_out", "uint8_t", "getDstFactorOut">,
    InterfaceMethod<"Get dst_factor_in", "uint8_t", "getDstFactorIn">,
    InterfaceMethod<"Get src_factor_out", "uint8_t", "getSrcFactorOut">,
    InterfaceMethod<"Get src_factor_in", "uint8_t", "getSrcFactorIn">,
    InterfaceMethod<"Get ALU opcode", "uint8_t", "getAluOpcode">,
    InterfaceMethod<"Get UseImm", "bool", "getUseImm">,
    InterfaceMethod<"Get immediate", "int16_t", "getImm">
  ];
}

#endif // VTA_INTERFACES