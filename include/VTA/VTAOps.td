
//======================================================================================================================// 
//                                           TABLEGEN SOURCE                                                            //
//======================================================================================================================//


//Generates VTAOps.h.inc, VTAOps.cpp.inc, VTAOpsDialect.h.inc/cpp.inc, VTAOpsTypes.h.inc/cpp.inc, VTAPasses.h.inc (see add_mlir_dialect in include/VTA/CMakeLists.txt).
#ifndef VTA_OPS
#define VTA_OPS

//file incuding the defs for the op interfaces
include "VTA/VTAInterfaces.td"

include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/IR/OpBase.td"
include "mlir/IR/SymbolInterfaces.td"
include "mlir/Pass/PassBase.td"



//Must match add_mlir_dialect(VTAOps vta) in include/VTA/CMakeLists.txt.
def VTADialect : Dialect {
    let name = "vta";
    let cppNamespace = "::mlir::vta";
    let emitAccessorPrefix = kEmitAccessorPrefix_Prefixed;
}

//Base class all VTA Ops inherit from.
//Requires vta.func as parent — parser rejects VTA ops outside a function.
class VTA_Op<string mnemonic, list<Trait> traits = []>
    : Op<VTADialect, mnemonic, traits # [HasParent<"FuncOp">]>;

//Base class for VTA structural ops (containers, not instructions).
//Doesn't require a parent, so FuncOp can use it.
class VTA_StructuralOp<string mnemonic, list<Trait> traits = []>
    : Op<VTADialect, mnemonic, traits>;



// --- NEW BASE CLASSES FOR INTERFACES ---

class VTA_Load_Op<string mnemonic, list<Trait> traits = []>
    : VTA_Op<mnemonic, !listconcat(traits, [VTA_LoadOpInterface])>;

class VTA_Store_Op<string mnemonic, list<Trait> traits = []>
    : VTA_Op<mnemonic, !listconcat(traits, [VTA_StoreOpInterface])>;

class VTA_Gemm_Op<string mnemonic, list<Trait> traits = []>
    : VTA_Op<mnemonic, !listconcat(traits, [VTA_GemmOpInterface])>;

class VTA_Alu_Op<string mnemonic, list<Trait> traits = []>
    : VTA_Op<mnemonic, !listconcat(traits, [VTA_AluOpInterface])>;




//Top-level container. Holds one block of VTA instructions.
def FuncOp : VTA_StructuralOp<"func", [
    IsolatedFromAbove,
    SingleBlock,
    Symbol
]> {
    let arguments = (ins SymbolNameAttr:$sym_name);
    let regions = (region SizedRegion<1>:$body);
    let assemblyFormat = [{
        $sym_name `(` attr-dict `)` $body
    }];
    let hasVerifier = 1;
}


//Verifiers in - lib/VTA/VTAOps.cpp 
//Serializers in vta-translate/vta-translate.cpp.






def FinishOp : VTA_Op<"finish", [Terminator]> {
    let arguments = (ins);
    let results = (outs);
    let assemblyFormat = "attr-dict";
    
}


def UcodeOp : VTA_Op<"ucode"> {
    let arguments = (ins ArrayAttr:$Records);

    let results = (outs);

    let assemblyFormat = "attr-dict";

    let hasVerifier=1;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                         LOAD OP CUSTOM
////////////////////////////////////////////////////////////////////////////////////////////////////////

//======================================================================================================================
// LOAD OPERATIONS
//======================================================================================================================

class VTA_LoadBase<string mnemonic> : VTA_Load_Op<mnemonic, [AttrSizedOperandSegments]> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,

        Optional<I16>:$SramBaseOperand,
        OptionalAttr<I16Attr>:$SramBase,
        Optional<I32>:$DramBaseOperand,
        OptionalAttr<I32Attr>:$DramBase,
        Optional<I16>:$YSizeOperand,
        OptionalAttr<I16Attr>:$YSize,
        Optional<I16>:$XSizeOperand,
        OptionalAttr<I16Attr>:$XSize,
        Optional<I16>:$XStrideOperand,
        OptionalAttr<I16Attr>:$XStride,
        Optional<I8>:$YPad0Operand,
        DefaultValuedAttr<I8Attr, "0">:$YPad0,
        Optional<I8>:$YPad1Operand,
        DefaultValuedAttr<I8Attr, "0">:$YPad1,
        Optional<I8>:$XPad0Operand,
        DefaultValuedAttr<I8Attr, "0">:$XPad0,
        Optional<I8>:$XPad1Operand,
        DefaultValuedAttr<I8Attr, "0">:$XPad1
    );

    let results = (outs);

    let assemblyFormat = [{
        `sram` ($SramBase^):($SramBaseOperand)? `,`
        `dram` ($DramBase^):($DramBaseOperand)? `,`
        `size` ($YSize^):($YSizeOperand)? `x` ($XSize^):($XSizeOperand)? `,`
        `stride` ($XStride^):($XStrideOperand)?
        (`y_pad0` $YPad0Operand^)?
        (`y_pad1` $YPad1Operand^)?
        (`x_pad0` $XPad0Operand^)?
        (`x_pad1` $XPad1Operand^)?
        attr-dict
    }];

    let hasVerifier = 1;
}

// LOAD INP
def LoadINPOp : VTA_Load_Op<"load_INP", [AttrSizedOperandSegments]> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,

        Optional<I16>:$SramBaseOperand,
        OptionalAttr<I16Attr>:$SramBase,
        Optional<I32>:$DramBaseOperand,
        OptionalAttr<I32Attr>:$DramBase,
        Optional<I16>:$YSizeOperand,
        OptionalAttr<I16Attr>:$YSize,
        Optional<I16>:$XSizeOperand,
        OptionalAttr<I16Attr>:$XSize,
        Optional<I16>:$XStrideOperand,
        OptionalAttr<I16Attr>:$XStride,
        Optional<I8>:$YPad0Operand,
        OptionalAttr<I8Attr>:$YPad0,
        Optional<I8>:$YPad1Operand,
        OptionalAttr<I8Attr>:$YPad1,
        Optional<I8>:$XPad0Operand,
        OptionalAttr<I8Attr>:$XPad0,
        Optional<I8>:$XPad1Operand,
        OptionalAttr<I8Attr>:$XPad1
    );

    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_LOAD; }
        uint8_t getMemoryType() { return 2; }
    }];

    let results = (outs);

    let assemblyFormat = [{
        `sram` ($SramBase^):($SramBaseOperand)? `,`
        `dram` ($DramBase^):($DramBaseOperand)? `,`
        `size` ($YSize^):($YSizeOperand)? `x` ($XSize^):($XSizeOperand)? `,`
        `stride` ($XStride^):($XStrideOperand)? `,`
        `pad` ($YPad0^):($YPad0Operand)? `,` ($YPad1^):($YPad1Operand)? `,`
              ($XPad0^):($XPad0Operand)? `,` ($XPad1^):($XPad1Operand)?
        attr-dict
    }];

    let hasVerifier = 1;
}

// LOAD UOP
def LoadUOPOp : VTA_LoadBase<"load_UOP"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_LOAD; }
        uint8_t getMemoryType() { return 0; }
    }];
}

// LOAD WGT
def LoadWGTOp : VTA_LoadBase<"load_WGT"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_LOAD; }
        uint8_t getMemoryType() { return 1; }
    }];
}

// LOAD ACC
def LoadACCOp : VTA_LoadBase<"load_ACC"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_LOAD; }
        uint8_t getMemoryType() { return 3; }
    }];
}

// LOAD NO-OP
def LoadNoOp : VTA_Load_Op<"load_NoOp"> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,

        DefaultValuedAttr<I8Attr, "0">:$MemoryType,
        DefaultValuedAttr<I16Attr, "0">:$SramBase,
        DefaultValuedAttr<I32Attr, "0">:$DramBase,
        DefaultValuedAttr<I16Attr, "0">:$YSize,
        DefaultValuedAttr<I16Attr, "0">:$XSize,
        DefaultValuedAttr<I16Attr, "0">:$XStride,
        DefaultValuedAttr<I8Attr, "0">:$YPad0,
        DefaultValuedAttr<I8Attr, "0">:$YPad1,
        DefaultValuedAttr<I8Attr, "0">:$XPad0,
        DefaultValuedAttr<I8Attr, "0">:$XPad1
    );

    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_LOAD; }
    }];

    let results = (outs);
    let assemblyFormat = "attr-dict";
    let hasVerifier = 1;
}


//======================================================================================================================
// STORE OPERATIONS
//======================================================================================================================

// STORE OUT
def StoreOUTOp : VTA_Store_Op<"store_OUT", [AttrSizedOperandSegments]> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,

        Optional<I16>:$SramBaseOperand,
        DefaultValuedAttr<I16Attr, "0">:$SramBase,
        Optional<I32>:$DramBaseOperand,
        OptionalAttr<I32Attr>:$DramBase,
        Optional<I16>:$YSizeOperand,
        DefaultValuedAttr<I16Attr, "1">:$YSize,
        Optional<I16>:$XSizeOperand,
        OptionalAttr<I16Attr>:$XSize,
        Optional<I16>:$XStrideOperand,
        DefaultValuedAttr<I16Attr, "1">:$XStride,
        Optional<I8>:$YPad0Operand,
        DefaultValuedAttr<I8Attr, "0">:$YPad0,
        Optional<I8>:$YPad1Operand,
        DefaultValuedAttr<I8Attr, "0">:$YPad1,
        Optional<I8>:$XPad0Operand,
        DefaultValuedAttr<I8Attr, "0">:$XPad0,
        Optional<I8>:$XPad1Operand,
        DefaultValuedAttr<I8Attr, "0">:$XPad1
    );

    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_STORE; }
        uint8_t getMemoryType() { return 4; }
    }];

    let results = (outs);

    let assemblyFormat = [{
        `dram` ($DramBase^):($DramBaseOperand)? `,`
        `size` ($XSize^):($XSizeOperand)?
        (`sram` $SramBaseOperand^)?
        (`ysize` $YSizeOperand^)?
        (`stride` $XStrideOperand^)?
        (`y_pad0` $YPad0Operand^)?
        (`y_pad1` $YPad1Operand^)?
        (`x_pad0` $XPad0Operand^)?
        (`x_pad1` $XPad1Operand^)?
        attr-dict
    }];

    let hasVerifier = 1;
}

// STORE NO-OP
def StoreNoOp : VTA_Store_Op<"store_NoOp"> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,

        DefaultValuedAttr<I8Attr, "4">:$MemoryType,
        DefaultValuedAttr<I16Attr, "0">:$SramBase,
        DefaultValuedAttr<I32Attr, "0">:$DramBase,
        DefaultValuedAttr<I16Attr, "0">:$YSize,
        DefaultValuedAttr<I16Attr, "0">:$XSize,
        DefaultValuedAttr<I16Attr, "0">:$XStride,
        DefaultValuedAttr<I8Attr, "0">:$YPad0,
        DefaultValuedAttr<I8Attr, "0">:$YPad1,
        DefaultValuedAttr<I8Attr, "0">:$XPad0,
        DefaultValuedAttr<I8Attr, "0">:$XPad1
    );

    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_STORE; }
    }];

    let results = (outs);
    let assemblyFormat = "attr-dict";
    let hasVerifier = 1;
}


//======================================================================================================================
// ALU OPERATIONS
//======================================================================================================================

// IMMEDIATE ALU OPERATIONS
class VTA_AluImmBase<string mnemonic> : VTA_Alu_Op<mnemonic, [AttrSizedOperandSegments]> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
        DefaultValuedAttr<I1Attr, "false">:$ResetReg,

        Optional<I8>:$UopBgnOperand,
        OptionalAttr<I8Attr>:$UopBgn,
        Optional<I8>:$UopEndOperand,
        OptionalAttr<I8Attr>:$UopEnd,
        Optional<I16>:$IterOutOperand,
        OptionalAttr<I16Attr>:$IterOut,
        Optional<I16>:$IterInOperand,
        OptionalAttr<I16Attr>:$IterIn,
        Optional<I8>:$DstFactorOutOperand,
        OptionalAttr<I8Attr>:$DstFactorOut,
        Optional<I8>:$DstFactorInOperand,
        OptionalAttr<I8Attr>:$DstFactorIn,
        Optional<I8>:$SrcFactorOutOperand,
        OptionalAttr<I8Attr>:$SrcFactorOut,
        Optional<I8>:$SrcFactorInOperand,
        OptionalAttr<I8Attr>:$SrcFactorIn,
        //I16Attr:$Imm
        Optional<I16>:$ImmOperand,
        OptionalAttr<I16Attr>:$Imm
    );

    let results = (outs);

    let assemblyFormat = [{
        (`imm` $Imm^):($ImmOperand)? `,`
        `uop` ($UopBgn^):($UopBgnOperand)? `to` ($UopEnd^):($UopEndOperand)? `,`
        `iter` ($IterOut^):($IterOutOperand)? `x` ($IterIn^):($IterInOperand)? `,`
        `dst` ($DstFactorOut^):($DstFactorOutOperand)? `,` ($DstFactorIn^):($DstFactorInOperand)? `,`
        `src` ($SrcFactorOut^):($SrcFactorOutOperand)? `,` ($SrcFactorIn^):($SrcFactorInOperand)?
        attr-dict
    }];

    let hasVerifier = 1;
}

// REGISTER ALU OPERATIONS
class VTA_AluRegBase<string mnemonic> : VTA_Alu_Op<mnemonic, [AttrSizedOperandSegments]> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
        DefaultValuedAttr<I1Attr, "false">:$ResetReg,

        Optional<I8>:$UopBgnOperand,
        OptionalAttr<I8Attr>:$UopBgn,
        Optional<I8>:$UopEndOperand,
        OptionalAttr<I8Attr>:$UopEnd,
        Optional<I16>:$IterOutOperand,
        OptionalAttr<I16Attr>:$IterOut,
        Optional<I16>:$IterInOperand,
        OptionalAttr<I16Attr>:$IterIn,
        Optional<I8>:$DstFactorOutOperand,
        OptionalAttr<I8Attr>:$DstFactorOut,
        Optional<I8>:$DstFactorInOperand,
        OptionalAttr<I8Attr>:$DstFactorIn,
        Optional<I8>:$SrcFactorOutOperand,
        OptionalAttr<I8Attr>:$SrcFactorOut,
        Optional<I8>:$SrcFactorInOperand,
        OptionalAttr<I8Attr>:$SrcFactorIn,
        Optional<I16>:$ImmOperand,
        DefaultValuedAttr<I16Attr, "0">:$Imm
    );

    let results = (outs);

    let assemblyFormat = [{
        `uop` ($UopBgn^):($UopBgnOperand)? `to` ($UopEnd^):($UopEndOperand)? `,`
        `iter` ($IterOut^):($IterOutOperand)? `x` ($IterIn^):($IterInOperand)? `,`
        `dst` ($DstFactorOut^):($DstFactorOutOperand)? `,` ($DstFactorIn^):($DstFactorInOperand)? `,`
        `src` ($SrcFactorOut^):($SrcFactorOutOperand)? `,` ($SrcFactorIn^):($SrcFactorInOperand)?
        (`imm_operand` $ImmOperand^)?
        attr-dict
    }];

    let hasVerifier = 1;
}

// IMMEDIATE ALU: MIN
def AluMinImmOp : VTA_AluImmBase<"alu_MIN_imm"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 0; }
        bool getUseImm() { return true; }
    }];
}

// IMMEDIATE ALU: MAX
def AluMaxImmOp : VTA_AluImmBase<"alu_MAX_imm"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 1; }
        bool getUseImm() { return true; }
    }];
}

// IMMEDIATE ALU: ADD
def AluAddImmOp : VTA_AluImmBase<"alu_ADD_imm"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 2; }
        bool getUseImm() { return true; }
    }];
}

// IMMEDIATE ALU: SHIFT
def AluShfImmOp : VTA_AluImmBase<"alu_SHF_imm"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 3; }
        bool getUseImm() { return true; }
    }];
}

// IMMEDIATE ALU: MUL
def AluMulImmOp : VTA_AluImmBase<"alu_MUL_imm"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 4; }
        bool getUseImm() { return true; }
    }];
}

// REGISTER ALU: MIN
def AluMinOp : VTA_AluRegBase<"alu_MIN"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 0; }
        bool getUseImm() { return false; }
    }];
}

// REGISTER ALU: MAX
def AluMaxOp : VTA_AluRegBase<"alu_MAX"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 1; }
        bool getUseImm() { return false; }
    }];
}

// REGISTER ALU: ADD
def AluAddOp : VTA_AluRegBase<"alu_ADD"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 2; }
        bool getUseImm() { return false; }
    }];
}

// REGISTER ALU: SHIFT
def AluShfOp : VTA_AluRegBase<"alu_SHF"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 3; }
        bool getUseImm() { return false; }
    }];
}

// REGISTER ALU: MUL
def AluMulOp : VTA_AluRegBase<"alu_MUL"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 4; }
        bool getUseImm() { return false; }
    }];
}

// ALU NO-OP
def AluNoOp : VTA_Alu_Op<"alu_NoOp"> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
        DefaultValuedAttr<I1Attr, "false">:$ResetReg,

        DefaultValuedAttr<I8Attr, "0">:$UopBgn,
        DefaultValuedAttr<I8Attr, "0">:$UopEnd,
        DefaultValuedAttr<I16Attr, "1">:$IterOut,
        DefaultValuedAttr<I16Attr, "1">:$IterIn,
        DefaultValuedAttr<I8Attr, "0">:$DstFactorOut,
        DefaultValuedAttr<I8Attr, "0">:$DstFactorIn,
        DefaultValuedAttr<I8Attr, "0">:$SrcFactorOut,
        DefaultValuedAttr<I8Attr, "0">:$SrcFactorIn,
        DefaultValuedAttr<I8Attr, "0">:$AluOpcode,
        DefaultValuedAttr<I1Attr, "false">:$UseImm,
        DefaultValuedAttr<I16Attr, "0">:$Imm
    );

    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
    }];

    let results = (outs);
    let assemblyFormat = "attr-dict";
    let hasVerifier = 1;
}


//======================================================================================================================
// GEMM OPERATIONS
//======================================================================================================================

// GEMM RESET
def GemmResetOp : VTA_Gemm_Op<"gemm_Reset", [AttrSizedOperandSegments]> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,

        Optional<I8>:$UopBgnOperand,
        OptionalAttr<I8Attr>:$UopBgn,
        Optional<I8>:$UopEndOperand,
        OptionalAttr<I8Attr>:$UopEnd,
        Optional<I16>:$IterOutOperand,
        OptionalAttr<I16Attr>:$IterOut,
        Optional<I16>:$IterInOperand,
        OptionalAttr<I16Attr>:$IterIn,
        Optional<I8>:$DstFactorOutOperand,
        OptionalAttr<I8Attr>:$DstFactorOut,
        Optional<I8>:$DstFactorInOperand,
        OptionalAttr<I8Attr>:$DstFactorIn,
        Optional<I8>:$SrcFactorOutOperand,
        DefaultValuedAttr<I8Attr, "0">:$SrcFactorOut,
        Optional<I8>:$SrcFactorInOperand,
        DefaultValuedAttr<I8Attr, "0">:$SrcFactorIn,
        Optional<I8>:$WgtFactorOutOperand,
        DefaultValuedAttr<I8Attr, "0">:$WgtFactorOut,
        Optional<I8>:$WgtFactorInOperand,
        DefaultValuedAttr<I8Attr, "0">:$WgtFactorIn
    );

    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_GEMM; }
        bool getResetReg() { return true; }
    }];

    let results = (outs);

    let assemblyFormat = [{
        `uop` ($UopBgn^):($UopBgnOperand)? `to` ($UopEnd^):($UopEndOperand)? `,`
        `iter` ($IterOut^):($IterOutOperand)? `x` ($IterIn^):($IterInOperand)? `,`
        `dst` ($DstFactorOut^):($DstFactorOutOperand)? `,` ($DstFactorIn^):($DstFactorInOperand)?
        (`src_factor_out` $SrcFactorOutOperand^)?
        (`src_factor_in` $SrcFactorInOperand^)?
        (`wgt_factor_out` $WgtFactorOutOperand^)?
        (`wgt_factor_in` $WgtFactorInOperand^)?
        attr-dict
    }];

    let hasVerifier = 1;
}

// GEMM ACCUMULATE
def GemmNoResetOp : VTA_Gemm_Op<"gemm", [AttrSizedOperandSegments]> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,

        Optional<I8>:$UopBgnOperand,
        OptionalAttr<I8Attr>:$UopBgn,
        Optional<I8>:$UopEndOperand,
        OptionalAttr<I8Attr>:$UopEnd,
        Optional<I16>:$IterOutOperand,
        OptionalAttr<I16Attr>:$IterOut,
        Optional<I16>:$IterInOperand,
        OptionalAttr<I16Attr>:$IterIn,
        Optional<I8>:$DstFactorOutOperand,
        OptionalAttr<I8Attr>:$DstFactorOut,
        Optional<I8>:$DstFactorInOperand,
        OptionalAttr<I8Attr>:$DstFactorIn,
        Optional<I8>:$SrcFactorOutOperand,
        OptionalAttr<I8Attr>:$SrcFactorOut,
        Optional<I8>:$SrcFactorInOperand,
        OptionalAttr<I8Attr>:$SrcFactorIn,
        Optional<I8>:$WgtFactorOutOperand,
        OptionalAttr<I8Attr>:$WgtFactorOut,
        Optional<I8>:$WgtFactorInOperand,
        OptionalAttr<I8Attr>:$WgtFactorIn
    );

    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_GEMM; }
        bool getResetReg() { return false; }
    }];

    let results = (outs);

    let assemblyFormat = [{
        `uop` ($UopBgn^):($UopBgnOperand)? `to` ($UopEnd^):($UopEndOperand)? `,`
        `iter` ($IterOut^):($IterOutOperand)? `x` ($IterIn^):($IterInOperand)? `,`
        `dst` ($DstFactorOut^):($DstFactorOutOperand)? `,` ($DstFactorIn^):($DstFactorInOperand)? `,`
        `src` ($SrcFactorOut^):($SrcFactorOutOperand)? `,` ($SrcFactorIn^):($SrcFactorInOperand)? `,`
        `wgt` ($WgtFactorOut^):($WgtFactorOutOperand)? `,` ($WgtFactorIn^):($WgtFactorInOperand)?
        attr-dict
    }];

    let hasVerifier = 1;
}

// GEMM NO-OP
def GemmNoOp : VTA_Gemm_Op<"gemm_NoOp"> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
        DefaultValuedAttr<I1Attr, "false">:$ResetReg,

        DefaultValuedAttr<I8Attr, "0">:$UopBgn,
        DefaultValuedAttr<I8Attr, "0">:$UopEnd,
        DefaultValuedAttr<I16Attr, "1">:$IterOut,
        DefaultValuedAttr<I16Attr, "1">:$IterIn,
        DefaultValuedAttr<I8Attr, "0">:$DstFactorOut,
        DefaultValuedAttr<I8Attr, "0">:$DstFactorIn,
        DefaultValuedAttr<I8Attr, "0">:$SrcFactorOut,
        DefaultValuedAttr<I8Attr, "0">:$SrcFactorIn,
        DefaultValuedAttr<I8Attr, "0">:$WgtFactorOut,
        DefaultValuedAttr<I8Attr, "0">:$WgtFactorIn
    );

    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_GEMM; }
    }];

    let results = (outs);
    let assemblyFormat = "attr-dict";
    let hasVerifier = 1;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                PASS DECLERATIONS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//Passes.cpp via MLIRVTAPassIncGen in include/VTA/CMakeLists.txt.
//Factory called from vta-opt/vta-opt.cpp and vta-translate/vta-translate.cpp.

def CheckStructure : Pass<"vta-check-structure", "ModuleOp"> {}
def CheckUcode : Pass<"vta-check-ucode", "ModuleOp"> {}

def CheckDependancy : Pass<"vta-check-dependancy", "ModuleOp"> {}

def TransformUcodeToLoadOp : Pass<"vta-transform-ucode-to-loadop", "ModuleOp"> {}

def TransformGeneralStructure : Pass<"vta-transform-general-structure", "ModuleOp"> {}


















































































//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                OLD FULL OPS  (Hiding spot safe from Diego)
//          https://www.youtube.com/watch?v=coS2CdNd7Io&pp=ygUhaW5nbG9yaW91cyBiYXN0YXJkcyBvcGVuaW5nIHNjZW5l
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

def LoadOp : VTA_Load_Op<"load_old", [AttrSizedOperandSegments]> {
    let arguments = (ins 
    DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
    DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
    DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
    DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
    //Selects the destination SRAM. 
    I8Attr:$MemoryType,
    //Offset within the destination SRAM
    Optional<I16>:$SramBaseOperand,
    OptionalAttr<I16Attr>:$SramBase,
    //Source byte address in DRAM
    Optional<I32>:$DramBaseOperand,
    OptionalAttr<I32Attr>:$DramBase,
    //Transfer shape: YSize rows of XSize elements, XStride bytes apart in DRAM.
    Optional<I16>:$YSizeOperand,
    OptionalAttr<I16Attr>:$YSize,
    Optional<I16>:$XSizeOperand,
    OptionalAttr<I16Attr>:$XSize,
    Optional<I16>:$XStrideOperand,
    OptionalAttr<I16Attr>:$XStride,
    //Padding around the transferred block
    Optional<I8>:$YPad0Operand,
    OptionalAttr<I8Attr>:$YPad0,
    Optional<I8>:$YPad1Operand,
    OptionalAttr<I8Attr>:$YPad1,
    Optional<I8>:$XPad0Operand,
    OptionalAttr<I8Attr>:$XPad0,
    Optional<I8>:$XPad1Operand,
    OptionalAttr<I8Attr>:$XPad1);

    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_LOAD; }
    }];

    let results = (outs);

    
    let builders = [
        OpBuilder<(ins
            "bool":$popPrevDep,
            "bool":$popNextDep,
            "bool":$pushPrevDep,
            "bool":$pushNextDep,
            "uint32_t":$memoryType,
            "uint32_t":$sramBase,
            "uint32_t":$dramBase,
            "uint32_t":$ySize,
            "uint32_t":$xSize,
            "uint32_t":$xStride,
            "uint32_t":$yPad0,
            "uint32_t":$yPad1,
            "uint32_t":$xPad0,
            "uint32_t":$xPad1
        )>
    ];
    
     //MemoryType in VTAOps.cpp
    let assemblyFormat = [{
        `mem` $MemoryType `,` 
        `sram` ($SramBase^):($SramBaseOperand)? `,`
        `dram` ($DramBase^):($DramBaseOperand)? `,`
        `size` ($YSize^):($YSizeOperand)? `x` ($XSize^):($XSizeOperand)? `,`
        `stride` ($XStride^):($XStrideOperand)? `,`
        `pad` ($YPad0^):($YPad0Operand)? `,` ($YPad1^):($YPad1Operand)? `,`
              ($XPad0^):($XPad0Operand)? `,` ($XPad1^):($XPad1Operand)?
        attr-dict
    }];
    let hasVerifier = 1;

}

def StoreOp : VTA_Store_Op<"store_old", [AttrSizedOperandSegments]> {
    let arguments = (ins
    DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
    DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
    DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
    DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
    //Selects the destination SRAM. 
    I8Attr:$MemoryType,
    //Offset within the destination SRAM
    Optional<I16>:$SramBaseOperand,
    OptionalAttr<I16Attr>:$SramBase,
    //Source byte address in DRAM
    Optional<I32>:$DramBaseOperand,
    OptionalAttr<I32Attr>:$DramBase,
    //Transfer shape: YSize rows of XSize elements, XStride bytes apart in DRAM.
    Optional<I16>:$YSizeOperand,
    OptionalAttr<I16Attr>:$YSize,
    Optional<I16>:$XSizeOperand,
    OptionalAttr<I16Attr>:$XSize,
    Optional<I16>:$XStrideOperand,
    OptionalAttr<I16Attr>:$XStride,
    //Padding around the transferred block
    Optional<I8>:$YPad0Operand,
    OptionalAttr<I8Attr>:$YPad0,
    Optional<I8>:$YPad1Operand,
    OptionalAttr<I8Attr>:$YPad1,
    Optional<I8>:$XPad0Operand,
    OptionalAttr<I8Attr>:$XPad0,
    Optional<I8>:$XPad1Operand,
    OptionalAttr<I8Attr>:$XPad1);

    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_STORE; }
    }];

    let results = (outs);
    
    let builders = [
        OpBuilder<(ins
            "bool":$popPrevDep,
            "bool":$popNextDep,
            "bool":$pushPrevDep,
            "bool":$pushNextDep,
            "uint32_t":$memoryType,
            "uint32_t":$sramBase,
            "uint32_t":$dramBase,
            "uint32_t":$ySize,
            "uint32_t":$xSize,
            "uint32_t":$xStride,
            "uint32_t":$yPad0,
            "uint32_t":$yPad1,
            "uint32_t":$xPad0,
            "uint32_t":$xPad1
        )>
    ];
    
     //MemoryType in VTAOps.cpp
    let assemblyFormat = [{
        `mem` $MemoryType `,`
        `sram` ($SramBase^):($SramBaseOperand)? `,`
        `dram` ($DramBase^):($DramBaseOperand)? `,`
        `size` ($YSize^):($YSizeOperand)? `x` ($XSize^):($XSizeOperand)? `,`
        `stride` ($XStride^):($XStrideOperand)? `,`
        `pad` ($YPad0^):($YPad0Operand)? `,` ($YPad1^):($YPad1Operand)? `,`
              ($XPad0^):($XPad0Operand)? `,` ($XPad1^):($XPad1Operand)?
        attr-dict
    }];
    let hasVerifier = 1;
}

def GemmOp : VTA_Gemm_Op<"gemm_old", [AttrSizedOperandSegments]> {
    let arguments = (ins
    DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
    DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
    DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
    DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
    I1Attr:$ResetReg,
    //Range of uop records to execute
    Optional<I8>:$UopBgnOperand,
    OptionalAttr<I8Attr>:$UopBgn,
    Optional<I8>:$UopEndOperand,
    OptionalAttr<I8Attr>:$UopEnd,
    //Loop shape: IterOut iterations of IterIn.
    Optional<I16>:$IterOutOperand,
    OptionalAttr<I16Attr>:$IterOut,
    Optional<I16>:$IterInOperand,
    OptionalAttr<I16Attr>:$IterIn,
    //Address multipliers applied when advancing the acc/src/wgt pointers.
    Optional<I8>:$DstFactorOutOperand,
    OptionalAttr<I8Attr>:$DstFactorOut,
    Optional<I8>:$DstFactorInOperand,
    OptionalAttr<I8Attr>:$DstFactorIn,
    Optional<I8>:$SrcFactorOutOperand,
    OptionalAttr<I8Attr>:$SrcFactorOut,
    Optional<I8>:$SrcFactorInOperand,
    OptionalAttr<I8Attr>:$SrcFactorIn,
    Optional<I8>:$WgtFactorOutOperand,
    OptionalAttr<I8Attr>:$WgtFactorOut,
    Optional<I8>:$WgtFactorInOperand,
    OptionalAttr<I8Attr>:$WgtFactorIn);

    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_GEMM; }
    }];

    let results = (outs);

    let builders = [
        OpBuilder<(ins
            "bool":$popPrevDep,
            "bool":$popNextDep,
            "bool":$pushPrevDep,
            "bool":$pushNextDep,
            "bool":$resetReg,
            "uint32_t":$uopBgn,
            "uint32_t":$uopEnd,
            "uint32_t":$iterOut,
            "uint32_t":$iterIn,
            "uint32_t":$dstFactorOut,
            "uint32_t":$dstFactorIn,
            "uint32_t":$srcFactorOut,
            "uint32_t":$srcFactorIn,
            "uint32_t":$wgtFactorOut,
            "uint32_t":$wgtFactorIn
        )>
    ];

    let assemblyFormat = [{
        `reset` $ResetReg `,`
        `uop` ($UopBgn^):($UopBgnOperand)? `to` ($UopEnd^):($UopEndOperand)? `,`
        `iter` ($IterOut^):($IterOutOperand)? `x` ($IterIn^):($IterInOperand)? `,`
        `dst` ($DstFactorOut^):($DstFactorOutOperand)? `,` ($DstFactorIn^):($DstFactorInOperand)? `,`
        `src` ($SrcFactorOut^):($SrcFactorOutOperand)? `,` ($SrcFactorIn^):($SrcFactorInOperand)? `,`
        `wgt` ($WgtFactorOut^):($WgtFactorOutOperand)? `,` ($WgtFactorIn^):($WgtFactorInOperand)?
        attr-dict
    }];
    let hasVerifier = 1;
}

def AluOp : VTA_Alu_Op<"alu_old", [AttrSizedOperandSegments]> {
    let arguments = (ins
    DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
    DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
    DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
    DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
    I1Attr:$ResetReg,
    Optional<I8>:$UopBgnOperand,
    OptionalAttr<I8Attr>:$UopBgn,
    Optional<I8>:$UopEndOperand,
    OptionalAttr<I8Attr>:$UopEnd,
    Optional<I16>:$IterOutOperand,
    OptionalAttr<I16Attr>:$IterOut,
    Optional<I16>:$IterInOperand,
    OptionalAttr<I16Attr>:$IterIn,
    Optional<I8>:$DstFactorOutOperand,
    OptionalAttr<I8Attr>:$DstFactorOut,
    Optional<I8>:$DstFactorInOperand,
    OptionalAttr<I8Attr>:$DstFactorIn,
    Optional<I8>:$SrcFactorOutOperand,
    OptionalAttr<I8Attr>:$SrcFactorOut,
    Optional<I8>:$SrcFactorInOperand,
    OptionalAttr<I8Attr>:$SrcFactorIn,
    //Selects MIN/MAX/ADD/SHR/MUL
    I8Attr:$AluOpcode,
    //If true, the second operand is Imm instead of an SRAM read.
    I1Attr:$UseImm,
    Optional<I16>:$ImmOperand,
    OptionalAttr<I16Attr>:$Imm);

    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
    }];

    let results = (outs);

    let builders = [
        OpBuilder<(ins
            "bool":$popPrevDep,
            "bool":$popNextDep,
            "bool":$pushPrevDep,
            "bool":$pushNextDep,
            "bool":$resetReg,
            "uint32_t":$uopBgn,
            "uint32_t":$uopEnd,
            "uint32_t":$iterOut,
            "uint32_t":$iterIn,
            "uint32_t":$dstFactorOut,
            "uint32_t":$dstFactorIn,
            "uint32_t":$srcFactorOut,
            "uint32_t":$srcFactorIn,
            "uint32_t":$aluOpcode,
            "bool":$useImm,
            "uint32_t":$imm
        )>
    ];

    let assemblyFormat = [{
        `reset` $ResetReg `,`
        `uop` ($UopBgn^):($UopBgnOperand)? `to` ($UopEnd^):($UopEndOperand)? `,`
        `iter` ($IterOut^):($IterOutOperand)? `x` ($IterIn^):($IterInOperand)? `,`
        `dst` ($DstFactorOut^):($DstFactorOutOperand)? `,` ($DstFactorIn^):($DstFactorInOperand)? `,`
        `src` ($SrcFactorOut^):($SrcFactorOutOperand)? `,` ($SrcFactorIn^):($SrcFactorInOperand)? `,`
        `alu` $AluOpcode `,`
        `imm` $UseImm `,` ($Imm^):($ImmOperand)?
        attr-dict
    }];
    let hasVerifier = 1;
}

#endif // VTA_OPS






