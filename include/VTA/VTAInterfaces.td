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
    InterfaceMethod<"Get SRAM base", "llvm::Optional<uint16_t>", "getSramBase", (ins), [{}], [{ return $_op.getSramBase(); }]>,
    InterfaceMethod<"Get DRAM base", "llvm::Optional<uint32_t>", "getDramBase", (ins), [{}], [{ return $_op.getDramBase(); }]>,
    InterfaceMethod<"Get Y size", "llvm::Optional<uint16_t>", "getYSize", (ins), [{}], [{ return $_op.getYSize(); }]>,
    InterfaceMethod<"Get X size", "llvm::Optional<uint16_t>", "getXSize", (ins), [{}], [{ return $_op.getXSize(); }]>,
    InterfaceMethod<"Get X stride", "llvm::Optional<uint16_t>", "getXStride", (ins), [{}], [{ return $_op.getXStride(); }]>,
    InterfaceMethod<"Get Y pad 0", "llvm::Optional<uint8_t>", "getYPad0", (ins), [{}], [{ return $_op.getYPad0(); }]>,
    InterfaceMethod<"Get Y pad 1", "llvm::Optional<uint8_t>", "getYPad1", (ins), [{}], [{ return $_op.getYPad1(); }]>,
    InterfaceMethod<"Get X pad 0", "llvm::Optional<uint8_t>", "getXPad0", (ins), [{}], [{ return $_op.getXPad0(); }]>,
    InterfaceMethod<"Get X pad 1", "llvm::Optional<uint8_t>", "getXPad1", (ins), [{}], [{ return $_op.getXPad1(); }]>,
    InterfaceMethod<"Get SramBase SSA operand", "::mlir::Value", "getSramBaseOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get DramBase SSA operand", "::mlir::Value", "getDramBaseOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get YSize SSA operand", "::mlir::Value", "getYSizeOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get XSize SSA operand", "::mlir::Value", "getXSizeOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get XStride SSA operand", "::mlir::Value", "getXStrideOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get YPad0 SSA operand", "::mlir::Value", "getYPad0Operand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get YPad1 SSA operand", "::mlir::Value", "getYPad1Operand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get XPad0 SSA operand", "::mlir::Value", "getXPad0Operand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get XPad1 SSA operand", "::mlir::Value", "getXPad1Operand", (ins), [{}], [{ return {}; }]>
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
    InterfaceMethod<"Get SRAM base", "llvm::Optional<uint16_t>", "getSramBase", (ins), [{}], [{ return $_op.getSramBase(); }]>,
    InterfaceMethod<"Get DRAM base", "llvm::Optional<uint32_t>", "getDramBase", (ins), [{}], [{ return $_op.getDramBase(); }]>,
    InterfaceMethod<"Get Y size", "llvm::Optional<uint16_t>", "getYSize", (ins), [{}], [{ return $_op.getYSize(); }]>,
    InterfaceMethod<"Get X size", "llvm::Optional<uint16_t>", "getXSize", (ins), [{}], [{ return $_op.getXSize(); }]>,
    InterfaceMethod<"Get X stride", "llvm::Optional<uint16_t>", "getXStride", (ins), [{}], [{ return $_op.getXStride(); }]>,
    InterfaceMethod<"Get Y pad 0", "llvm::Optional<uint8_t>", "getYPad0", (ins), [{}], [{ return $_op.getYPad0(); }]>,
    InterfaceMethod<"Get Y pad 1", "llvm::Optional<uint8_t>", "getYPad1", (ins), [{}], [{ return $_op.getYPad1(); }]>,
    InterfaceMethod<"Get X pad 0", "llvm::Optional<uint8_t>", "getXPad0", (ins), [{}], [{ return $_op.getXPad0(); }]>,
    InterfaceMethod<"Get X pad 1", "llvm::Optional<uint8_t>", "getXPad1", (ins), [{}], [{ return $_op.getXPad1(); }]>,
    InterfaceMethod<"Get SramBase SSA operand", "::mlir::Value", "getSramBaseOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get DramBase SSA operand", "::mlir::Value", "getDramBaseOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get YSize SSA operand", "::mlir::Value", "getYSizeOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get XSize SSA operand", "::mlir::Value", "getXSizeOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get XStride SSA operand", "::mlir::Value", "getXStrideOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get YPad0 SSA operand", "::mlir::Value", "getYPad0Operand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get YPad1 SSA operand", "::mlir::Value", "getYPad1Operand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get XPad0 SSA operand", "::mlir::Value", "getXPad0Operand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get XPad1 SSA operand", "::mlir::Value", "getXPad1Operand", (ins), [{}], [{ return {}; }]>
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
    InterfaceMethod<"Get UOP begin", "llvm::Optional<uint8_t>", "getUopBgn", (ins), [{}], [{ return $_op.getUopBgn(); }]>,
    InterfaceMethod<"Get UOP end", "llvm::Optional<uint8_t>", "getUopEnd", (ins), [{}], [{ return $_op.getUopEnd(); }]>,
    InterfaceMethod<"Get iter_out", "llvm::Optional<uint16_t>", "getIterOut", (ins), [{}], [{ return $_op.getIterOut(); }]>,
    InterfaceMethod<"Get iter_in", "llvm::Optional<uint16_t>", "getIterIn", (ins), [{}], [{ return $_op.getIterIn(); }]>,
    InterfaceMethod<"Get dst_factor_out", "llvm::Optional<uint8_t>", "getDstFactorOut", (ins), [{}], [{ return $_op.getDstFactorOut(); }]>,
    InterfaceMethod<"Get dst_factor_in", "llvm::Optional<uint8_t>", "getDstFactorIn", (ins), [{}], [{ return $_op.getDstFactorIn(); }]>,
    InterfaceMethod<"Get src_factor_out", "llvm::Optional<uint8_t>", "getSrcFactorOut", (ins), [{}], [{ return $_op.getSrcFactorOut(); }]>,
    InterfaceMethod<"Get src_factor_in", "llvm::Optional<uint8_t>", "getSrcFactorIn", (ins), [{}], [{ return $_op.getSrcFactorIn(); }]>,
    InterfaceMethod<"Get wgt_factor_out", "llvm::Optional<uint8_t>", "getWgtFactorOut", (ins), [{}], [{ return $_op.getWgtFactorOut(); }]>,
    InterfaceMethod<"Get wgt_factor_in", "llvm::Optional<uint8_t>", "getWgtFactorIn", (ins), [{}], [{ return $_op.getWgtFactorIn(); }]>,
    InterfaceMethod<"Get UopBgn SSA operand", "::mlir::Value", "getUopBgnOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get UopEnd SSA operand", "::mlir::Value", "getUopEndOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get IterOut SSA operand", "::mlir::Value", "getIterOutOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get IterIn SSA operand", "::mlir::Value", "getIterInOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get DstFactorOut SSA operand", "::mlir::Value", "getDstFactorOutOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get DstFactorIn SSA operand", "::mlir::Value", "getDstFactorInOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get SrcFactorOut SSA operand", "::mlir::Value", "getSrcFactorOutOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get SrcFactorIn SSA operand", "::mlir::Value", "getSrcFactorInOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get WgtFactorOut SSA operand", "::mlir::Value", "getWgtFactorOutOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get WgtFactorIn SSA operand", "::mlir::Value", "getWgtFactorInOperand", (ins), [{}], [{ return {}; }]>
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
    InterfaceMethod<"Get UOP begin", "llvm::Optional<uint8_t>", "getUopBgn", (ins), [{}], [{ return $_op.getUopBgn(); }]>,
    InterfaceMethod<"Get UOP end", "llvm::Optional<uint8_t>", "getUopEnd", (ins), [{}], [{ return $_op.getUopEnd(); }]>,
    InterfaceMethod<"Get iter_out", "llvm::Optional<uint16_t>", "getIterOut", (ins), [{}], [{ return $_op.getIterOut(); }]>,
    InterfaceMethod<"Get iter_in", "llvm::Optional<uint16_t>", "getIterIn", (ins), [{}], [{ return $_op.getIterIn(); }]>,
    InterfaceMethod<"Get dst_factor_out", "llvm::Optional<uint8_t>", "getDstFactorOut", (ins), [{}], [{ return $_op.getDstFactorOut(); }]>,
    InterfaceMethod<"Get dst_factor_in", "llvm::Optional<uint8_t>", "getDstFactorIn", (ins), [{}], [{ return $_op.getDstFactorIn(); }]>,
    InterfaceMethod<"Get src_factor_out", "llvm::Optional<uint8_t>", "getSrcFactorOut", (ins), [{}], [{ return $_op.getSrcFactorOut(); }]>,
    InterfaceMethod<"Get src_factor_in", "llvm::Optional<uint8_t>", "getSrcFactorIn", (ins), [{}], [{ return $_op.getSrcFactorIn(); }]>,
    InterfaceMethod<"Get UopBgn SSA operand", "::mlir::Value", "getUopBgnOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get UopEnd SSA operand", "::mlir::Value", "getUopEndOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get IterOut SSA operand", "::mlir::Value", "getIterOutOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get IterIn SSA operand", "::mlir::Value", "getIterInOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get DstFactorOut SSA operand", "::mlir::Value", "getDstFactorOutOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get DstFactorIn SSA operand", "::mlir::Value", "getDstFactorInOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get SrcFactorOut SSA operand", "::mlir::Value", "getSrcFactorOutOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get SrcFactorIn SSA operand", "::mlir::Value", "getSrcFactorInOperand", (ins), [{}], [{ return {}; }]>,
    InterfaceMethod<"Get ALU opcode", "uint8_t", "getAluOpcode">,
    InterfaceMethod<"Get UseImm", "bool", "getUseImm">,
    InterfaceMethod<"Get immediate", "llvm::Optional<uint16_t>", "getImm">,
    InterfaceMethod<"Get Imm SSA operand", "::mlir::Value", "getImmOperand", (ins), [{}], [{ return {}; }]>
  ];
}

#endif // VTA_INTERFACES
