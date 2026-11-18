
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



def LoadOp : VTA_Load_Op<"load"> {
    let arguments = (ins 
    DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
    DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
    DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
    DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
    //Selects the destination SRAM. 
    I8Attr:$MemoryType,
    //Offset within the destination SRAM
    I16Attr:$SramBase,
    //Source byte address in DRAM
    I32Attr:$DramBase,
    //Transfer shape: YSize rows of XSize elements, XStride bytes apart in DRAM.
    I16Attr:$YSize,
    I16Attr:$XSize,
    I16Attr:$XStride,
    //Padding around the transferred block
    I8Attr:$YPad0,
    I8Attr:$YPad1,
    I8Attr:$XPad0,
    I8Attr:$XPad1);

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
        `mem` custom<MemoryType>($MemoryType) `,` 
        `sram` $SramBase `,`
        `dram` $DramBase `,`
        `size` $YSize `x` $XSize `,`
        `stride` $XStride `,`
        `pad` $YPad0 `,` $YPad1 `,` $XPad0 `,` $XPad1
        attr-dict
    }];
    let hasVerifier = 1;

}


def StoreOp : VTA_Store_Op<"store"> {
    let arguments = (ins
    DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
    DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
    DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
    DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
    //Selects the destination SRAM. 
    I8Attr:$MemoryType,
    //Offset within the destination SRAM
    I16Attr:$SramBase,
    //Source byte address in DRAM
    I32Attr:$DramBase,
    //Transfer shape: YSize rows of XSize elements, XStride bytes apart in DRAM.
    I16Attr:$YSize,
    I16Attr:$XSize,
    I16Attr:$XStride,
    //Padding around the transferred block
    I8Attr:$YPad0,
    I8Attr:$YPad1,
    I8Attr:$XPad0,
    I8Attr:$XPad1);

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
        `mem` custom<MemoryType>($MemoryType) `,`
        `sram` $SramBase `,`
        `dram` $DramBase `,`
        `size` $YSize `x` $XSize `,`
        `stride` $XStride `,`
        `pad` $YPad0 `,` $YPad1 `,` $XPad0 `,` $XPad1
        attr-dict
    }];
    let hasVerifier = 1;
}


def GemmOp : VTA_Gemm_Op<"gemm"> {
    let arguments = (ins
    DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
    DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
    DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
    DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
    I1Attr:$ResetReg,
    //Range of uop records to execute
    I8Attr:$UopBgn,
    I8Attr:$UopEnd,
    //Loop shape: IterOut iterations of IterIn.
    I16Attr:$IterOut,
    I16Attr:$IterIn,
    //Address multipliers applied when advancing the acc/src/wgt pointers.
    I8Attr:$DstFactorOut,
    I8Attr:$DstFactorIn,
    I8Attr:$SrcFactorOut,
    I8Attr:$SrcFactorIn,
    I8Attr:$WgtFactorOut,
    I8Attr:$WgtFactorIn);

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
        `uop` $UopBgn `to` $UopEnd `,`
        `iter` $IterOut `x` $IterIn `,`
        `dst` $DstFactorOut `,` $DstFactorIn `,`
        `src` $SrcFactorOut `,` $SrcFactorIn `,`
        `wgt` $WgtFactorOut `,` $WgtFactorIn
        attr-dict
    }];
    let hasVerifier = 1;
}

def AluOp : VTA_Alu_Op<"alu"> {
    let arguments = (ins
    DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
    DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
    DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
    DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
    I1Attr:$ResetReg,
    I8Attr:$UopBgn,
    I8Attr:$UopEnd,
    I16Attr:$IterOut,
    I16Attr:$IterIn,
    I8Attr:$DstFactorOut,
    I8Attr:$DstFactorIn,
    I8Attr:$SrcFactorOut,
    I8Attr:$SrcFactorIn,
    //Selects MIN/MAX/ADD/SHR/MUL
    I8Attr:$AluOpcode,
    //If true, the second operand is Imm instead of an SRAM read.
    I1Attr:$UseImm,
    I16Attr:$Imm);

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
        `uop` $UopBgn `to` $UopEnd `,`
        `iter` $IterOut `x` $IterIn `,`
        `dst` $DstFactorOut `,` $DstFactorIn `,`
        `src` $SrcFactorOut `,` $SrcFactorIn `,`
        `alu` $AluOpcode `,`
        `imm` $UseImm `,` $Imm
        attr-dict
    }];
    let hasVerifier = 1;
}


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

class VTA_LoadBase<string mnemonic> : VTA_Load_Op<mnemonic> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,

        I16Attr:$SramBase,
        I32Attr:$DramBase,
        I16Attr:$YSize,
        I16Attr:$XSize,
        I16Attr:$XStride,
        DefaultValuedAttr<I8Attr, "0">:$YPad0,
        DefaultValuedAttr<I8Attr, "0">:$YPad1,
        DefaultValuedAttr<I8Attr, "0">:$XPad0,
        DefaultValuedAttr<I8Attr, "0">:$XPad1
    );

    let results = (outs);

    let assemblyFormat = [{
        `sram` $SramBase `,`
        `dram` $DramBase `,`
        `size` $YSize `x` $XSize `,`
        `stride` $XStride
        attr-dict
    }];

    let hasVerifier = 1;
}

def LoadINPOp : VTA_Load_Op<"load_INP"> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,

        I16Attr:$SramBase,
        I32Attr:$DramBase,
        I16Attr:$YSize,
        I16Attr:$XSize,
        I16Attr:$XStride,
        I8Attr:$YPad0,
        I8Attr:$YPad1,
        I8Attr:$XPad0,
        I8Attr:$XPad1
    );

    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_LOAD; }
        uint8_t getMemoryType() { return 2; }
    }];

    let results = (outs);

    let assemblyFormat = [{
        `sram` $SramBase `,`
        `dram` $DramBase `,`
        `size` $YSize `x` $XSize `,`
        `stride` $XStride `,`
        `pad` $YPad0 `,` $YPad1 `,` $XPad0 `,` $XPad1
        attr-dict
    }];

    let hasVerifier = 1;
}


def LoadUOPOp : VTA_LoadBase<"load_UOP"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_LOAD; }
        uint8_t getMemoryType() { return 0; }
    }];
}

def LoadWGTOp : VTA_LoadBase<"load_WGT"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_LOAD; }
        uint8_t getMemoryType() { return 1; }
    }];
}

def LoadACCOp : VTA_LoadBase<"load_ACC"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_LOAD; }
        uint8_t getMemoryType() { return 3; }
    }];
}

def LoadNoOp : VTA_Load_Op<"load_NoOp"> {
    let arguments = (ins 
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
        // Defaulted to 0 so it acts like a zero-size load
        DefaultValuedAttr<I8Attr, "0">:$MemoryType,
        DefaultValuedAttr<I16Attr, "0">:$SramBase,
        DefaultValuedAttr<I32Attr, "0">:$DramBase,
        DefaultValuedAttr<I16Attr, "0">:$YSize,
        DefaultValuedAttr<I16Attr, "0">:$XSize,
        DefaultValuedAttr<I16Attr, "0">:$XStride,
        DefaultValuedAttr<I8Attr, "0">:$YPad0,
        DefaultValuedAttr<I8Attr, "0">:$YPad1,
        DefaultValuedAttr<I8Attr, "0">:$XPad0,
        DefaultValuedAttr<I8Attr, "0">:$XPad1);

    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_LOAD; }
    }];

    let results = (outs);
    
    // Same format as LoadOp
    let assemblyFormat = "attr-dict";
    let hasVerifier = 1;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                         STORE OP CUSTOM
////////////////////////////////////////////////////////////////////////////////////////////////////////
def StoreOUTOp : VTA_Store_Op<"store_OUT"> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
        DefaultValuedAttr<I16Attr, "0">:$SramBase,
        I32Attr:$DramBase,
        DefaultValuedAttr<I16Attr, "1">:$YSize,
        I16Attr:$XSize,
        DefaultValuedAttr<I16Attr, "1">:$XStride,
        DefaultValuedAttr<I8Attr, "0">:$YPad0,
        DefaultValuedAttr<I8Attr, "0">:$YPad1,
        DefaultValuedAttr<I8Attr, "0">:$XPad0,
        DefaultValuedAttr<I8Attr, "0">:$XPad1);

    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_STORE; }
        uint8_t getMemoryType() { return 4; }
    }];

    let results = (outs);
    let assemblyFormat = [{ `dram` $DramBase `,` `size` $XSize attr-dict }];
    let hasVerifier = 1;
}

def StoreNoOp : VTA_Store_Op<"store_NoOp"> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
        // Default 4 (OUT), not 0 like LoadNoOp: the simulator rejects any other store type
        DefaultValuedAttr<I8Attr, "4">:$MemoryType,
        DefaultValuedAttr<I16Attr, "0">:$SramBase,
        DefaultValuedAttr<I32Attr, "0">:$DramBase,
        DefaultValuedAttr<I16Attr, "0">:$YSize,
        DefaultValuedAttr<I16Attr, "0">:$XSize,
        DefaultValuedAttr<I16Attr, "0">:$XStride,
        DefaultValuedAttr<I8Attr, "0">:$YPad0,
        DefaultValuedAttr<I8Attr, "0">:$YPad1,
        DefaultValuedAttr<I8Attr, "0">:$XPad0,
        DefaultValuedAttr<I8Attr, "0">:$XPad1);

    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_STORE; }
    }];

    let results = (outs);
    let assemblyFormat = "attr-dict";
    let hasVerifier = 1;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            ALU CUSTOM 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Immediate form: dst = f(dst, Imm). SrcFactors are unused, so they are fixed to 0.
class VTA_AluImmBase<string mnemonic> : VTA_Alu_Op<mnemonic> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
        DefaultValuedAttr<I1Attr, "false">:$ResetReg,
        I8Attr:$UopBgn,
        I8Attr:$UopEnd,
        DefaultValuedAttr<I16Attr, "1">:$IterOut,
        DefaultValuedAttr<I16Attr, "1">:$IterIn,
        DefaultValuedAttr<I8Attr, "0">:$DstFactorOut,
        DefaultValuedAttr<I8Attr, "0">:$DstFactorIn,
        DefaultValuedAttr<I8Attr, "0">:$SrcFactorOut,
        DefaultValuedAttr<I8Attr, "0">:$SrcFactorIn,
        I16Attr:$Imm);
    let results = (outs);
    let assemblyFormat = [{ `imm` $Imm `,` `uop` $UopBgn `to` $UopEnd attr-dict }];
    let hasVerifier = 1;
}

class VTA_AluRegBase<string mnemonic> : VTA_Alu_Op<mnemonic> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
        DefaultValuedAttr<I1Attr, "false">:$ResetReg,
        I8Attr:$UopBgn,
        I8Attr:$UopEnd,
        DefaultValuedAttr<I16Attr, "1">:$IterOut,
        DefaultValuedAttr<I16Attr, "1">:$IterIn,
        DefaultValuedAttr<I8Attr, "0">:$DstFactorOut,
        DefaultValuedAttr<I8Attr, "0">:$DstFactorIn,
        DefaultValuedAttr<I8Attr, "0">:$SrcFactorOut,
        DefaultValuedAttr<I8Attr, "0">:$SrcFactorIn,
        DefaultValuedAttr<I16Attr, "0">:$Imm);
    let results = (outs);
    let assemblyFormat = [{ `uop` $UopBgn `to` $UopEnd attr-dict }];
    let hasVerifier = 1;
}

// ----- immediate ops (AluOpcode: MIN 0, MAX 1, ADD 2, SHR 3, MUL 4) -----
def AluMinImmOp : VTA_AluImmBase<"alu_MIN_imm"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 0; }
        bool getUseImm() { return true; }
    }];
    let hasVerifier = 1;
}
def AluMaxImmOp : VTA_AluImmBase<"alu_MAX_imm"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 1; }
        bool getUseImm() { return true; }
    }];
    let hasVerifier = 1;
}
def AluAddImmOp : VTA_AluImmBase<"alu_ADD_imm"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 2; }
        bool getUseImm() { return true; }
    }];
    let hasVerifier = 1;
}
def AluShrImmOp : VTA_AluImmBase<"alu_SHR_imm"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 3; }
        bool getUseImm() { return true; }
    }];
    let hasVerifier = 1;
}
def AluMulImmOp : VTA_AluImmBase<"alu_MUL_imm"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 4; }
        bool getUseImm() { return true; }
    }];
    let hasVerifier = 1;
}

// ----- register ops -----
def AluMinOp : VTA_AluRegBase<"alu_MIN"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 0; }
        bool getUseImm() { return false; }
    }];
    let hasVerifier = 1;
}
def AluMaxOp : VTA_AluRegBase<"alu_MAX"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 1; }
        bool getUseImm() { return false; }
    }];
    let hasVerifier = 1;
}
def AluAddOp : VTA_AluRegBase<"alu_ADD"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 2; }
        bool getUseImm() { return false; }
    }];
    let hasVerifier = 1;
}
def AluShrOp : VTA_AluRegBase<"alu_SHR"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 3; }
        bool getUseImm() { return false; }
    }];
    let hasVerifier = 1;
}
def AluMulOp : VTA_AluRegBase<"alu_MUL"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
        uint8_t getAluOpcode() { return 4; }
        bool getUseImm() { return false; }
    }];
    let hasVerifier = 1;
}

// ----- no-op: empty uop range, only the dependency flags matter -----
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
        // Must stay a valid opcode (0-4): the simulator aborts on an unknown one even for an empty range
        DefaultValuedAttr<I8Attr, "0">:$AluOpcode,
        DefaultValuedAttr<I1Attr, "false">:$UseImm,
        DefaultValuedAttr<I16Attr, "0">:$Imm);
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_ALU; }
    }];
    let results = (outs);
    let assemblyFormat = "attr-dict";
    let hasVerifier = 1;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            GEMM CUSTOM 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Shared fields. ResetReg is fixed by each op (a method), everything else is a defaulted attribute.
class VTA_GemmBase<string mnemonic> : VTA_Gemm_Op<mnemonic> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep,
        I8Attr:$UopBgn,
        I8Attr:$UopEnd,
        DefaultValuedAttr<I16Attr, "1">:$IterOut,
        DefaultValuedAttr<I16Attr, "1">:$IterIn,
        DefaultValuedAttr<I8Attr, "0">:$DstFactorOut,
        DefaultValuedAttr<I8Attr, "0">:$DstFactorIn,
        DefaultValuedAttr<I8Attr, "0">:$SrcFactorOut,
        DefaultValuedAttr<I8Attr, "0">:$SrcFactorIn,
        DefaultValuedAttr<I8Attr, "0">:$WgtFactorOut,
        DefaultValuedAttr<I8Attr, "0">:$WgtFactorIn);
    let results = (outs);
    let assemblyFormat = [{ `uop` $UopBgn `to` $UopEnd attr-dict }];
    let hasVerifier = 1;
}

// Zero the ACC rows addressed by the uops. SrcFactor and WgtFactor are ignored by the simulator.
def GemmResetOp : VTA_GemmBase<"gemm_Reset"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_GEMM; }
        bool getResetReg() { return true; }
    }];
    let hasVerifier = 1;
}

// acc += inp . wgt
def GemmNoResetOp : VTA_GemmBase<"gemm_NoReset"> {
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_GEMM; }
        bool getResetReg() { return false; }
    }];
    let hasVerifier = 1;
}

// No-op: empty uop range, only the dependency flags matter.
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
        DefaultValuedAttr<I8Attr, "0">:$WgtFactorIn);
    let extraClassDeclaration = [{
        uint8_t getOpcode() { return VTA_OPCODE_GEMM; }
    }];
    let results = (outs);
    let assemblyFormat = "attr-dict";
    let hasVerifier = 1;
}


























//Passes.cpp via MLIRVTAPassIncGen in include/VTA/CMakeLists.txt.
//Factory called from vta-opt/vta-opt.cpp and vta-translate/vta-translate.cpp.

def CheckStructure : Pass<"vta-check-structure", "ModuleOp"> {}
def CheckUcode : Pass<"vta-check-ucode", "ModuleOp"> {}

def CheckDependancy : Pass<"vta-check-dependancy", "ModuleOp"> {}

def TransformUcodeToLoadOp : Pass<"vta-transform-ucode-to-loadop", "ModuleOp"> {}

def TransformGeneralStructure : Pass<"vta-transform-general-structure", "ModuleOp"> {}

//def TransformInsertDummyFinishLoad : Pass<"vta-insert-dummy-finish-load", "ModuleOp"> {}






#endif // VTA_OPS
