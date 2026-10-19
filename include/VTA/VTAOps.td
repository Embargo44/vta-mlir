//======================================================================================================================// 
//                                           TABLEGEN SOURCE                                                            //
//======================================================================================================================//


//Generates VTAOps.h.inc, VTAOps.cpp.inc, VTAOpsDialect.h.inc/cpp.inc, VTAOpsTypes.h.inc/cpp.inc, VTAPasses.h.inc (see add_mlir_dialect in include/VTA/CMakeLists.txt).
#ifndef VTA_OPS
#define VTA_OPS


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



def LoadOp : VTA_Op<"load"> {
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


def StoreOp : VTA_Op<"store"> {
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


def GemmOp : VTA_Op<"gemm"> {
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

def AluOp : VTA_Op<"alu"> {
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


def LoadNoOp : VTA_Op<"load_noop"> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep);
    let results = (outs);
    let assemblyFormat = "attr-dict";
    let hasVerifier = 1;
}

def StoreNoOp : VTA_Op<"store_noop"> {
    let arguments = (ins
        DefaultValuedAttr<I1Attr, "false">:$PopPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PopNextDep,
        DefaultValuedAttr<I1Attr, "false">:$PushPrevDep,
        DefaultValuedAttr<I1Attr, "false">:$PushNextDep);
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
def TransformNoOps : Pass<"vta-transform-noops", "ModuleOp"> {}

def TransformGeneralStructure : Pass<"vta-transform-general-structure", "ModuleOp"> {}








#endif // VTA_OPS