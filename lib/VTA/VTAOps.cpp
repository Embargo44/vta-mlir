//Verifier implementations. Fills in verify() declared by VTAOps.td.

// Standard MLIR infrastructure.
#include "mlir/Support/LogicalResult.h"
#include "mlir/IR/OpImplementation.h"

// Generated from VTAOps.td
#include "VTA/VTAOps.h"
#include "VTA/VTADialect.h"

#define GET_OP_CLASSES
#include "VTA/VTAOps.cpp.inc"


using namespace mlir;
using namespace mlir::vta;


LogicalResult LoadOp::verify() {
    if (getMemoryType() > 3)
        return emitOpError("MemoryType must be 0-3 (UOP, WGT, INP, ACC)");
    if (getYPad0() > 15)
        return emitOpError("YPad0 must be 0-15");
    if (getYPad1() > 15)
        return emitOpError("YPad1 must be 0-15");
    if (getXPad0() > 15)
        return emitOpError("XPad0 must be 0-15");
    if (getXPad1() > 15)
        return emitOpError("XPad1 must be 0-15");
    return success();
}

LogicalResult StoreOp::verify() {
    if (getMemoryType() != 4)
        return emitOpError("MemoryType must be 4 (OUT)");
    if (getYPad0() > 15)
        return emitOpError("YPad0 must be 0-15");
    if (getYPad1() > 15)
        return emitOpError("YPad1 must be 0-15");
    if (getXPad0() > 15)
        return emitOpError("XPad0 must be 0-15");
    if (getXPad1() > 15)
        return emitOpError("XPad1 must be 0-15");
    return success();
}

LogicalResult GemmOp::verify() {
    if (getUopBgn() > 127)
        return emitOpError("UopBgn must be 0-127");
    if (getUopBgn() > getUopEnd())
        return emitOpError("UopBgn must be <= UopEnd");
    if (getIterOut() < 1)
        return emitOpError("IterOut must be >= 1");
    if (getIterIn() < 1)
        return emitOpError("IterIn must be >= 1");
    if (getIterOut() > 16383)
        return emitOpError("IterOut must be <= 16383");
    if (getIterIn() > 16383)
        return emitOpError("IterIn must be <= 16383");
    if (getDstFactorOut() > 127)
        return emitOpError("DstFactorOut must be 0-127");
    if (getDstFactorIn() > 127)
        return emitOpError("DstFactorIn must be 0-127");
    if (getSrcFactorOut() > 127)
        return emitOpError("SrcFactorOut must be 0-127");
    if (getSrcFactorIn() > 127)
        return emitOpError("SrcFactorIn must be 0-127");
    if (getWgtFactorOut() > 127)
        return emitOpError("WgtFactorOut must be 0-127");
    if (getWgtFactorIn() > 127)
        return emitOpError("WgtFactorIn must be 0-127");
    return success();
}

LogicalResult AluOp::verify() {
    if (getUopBgn() > 127)
        return emitOpError("UopBgn must be 0-127");
    if (getUopBgn() > getUopEnd())
        return emitOpError("UopBgn must be <= UopEnd");
    if (getIterOut() < 1)
        return emitOpError("IterOut must be >= 1");
    if (getIterIn() < 1)
        return emitOpError("IterIn must be >= 1");
    if (getIterOut() > 16383)
        return emitOpError("IterOut must be <= 16383");
    if (getIterIn() > 16383)
        return emitOpError("IterIn must be <= 16383");
    if (getDstFactorOut() > 127)
        return emitOpError("DstFactorOut must be 0-127");
    if (getDstFactorIn() > 127)
        return emitOpError("DstFactorIn must be 0-127");
    if (getSrcFactorOut() > 127)
        return emitOpError("SrcFactorOut must be 0-127");
    if (getSrcFactorIn() > 127)
        return emitOpError("SrcFactorIn must be 0-127");
    if (getAluOpcode() > 4)
        return emitOpError("AluOpcode must be 0-4 (MIN, MAX, ADD, SHR, MUL)");
    return success();
}


LogicalResult UcodeOp::verify() {
    if (getRecords().empty())
        return emitOpError("Records must not be empty");
    for (Attribute a : getRecords()) {          //more readable then before (diego)
        auto triple = a.dyn_cast<ArrayAttr>();
        if (!triple || triple.size() != 3)
            return emitOpError("each record must be a triple (dst, src, wgt)");   
    }
    return success();
}


LogicalResult LoadNoOp::verify() {
    if (getPopPrevDep())
        return emitOpError("PopPrevDep has no effect on a load no-op");
    if (getPushPrevDep())
        return emitOpError("PushPrevDep has no effect on a load no-op");
    return success();
}

LogicalResult StoreNoOp::verify() {
    if (getPopNextDep())
        return emitOpError("PopNextDep has no effect on a store no-op");
    if (getPushNextDep())
        return emitOpError("PushNextDep has no effect on a store no-op");
    return success();
}