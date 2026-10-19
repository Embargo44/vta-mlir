//Verifier implementations. Fills in verify() declared by VTAOps.td.
//===----------------------------------------------------------------------===//
// FuncOp
//===----------------------------------------------------------------------===//

LogicalResult FuncOp::verify() {
    //Body must not be empty. At minimum a vta.finish terminator.
    Block &body = getBody().front();
    if (body.empty()) {
        return emitOpError("function body must not be empty");
    }

    //Every op in the body must be a VTA op (except the terminator, which
    //is vta.finish and is also a VTA op).
    for (Operation &op : body) {
        if (op.getDialect() != getOperation()->getDialect()) {
            return op.emitOpError("expected only VTA ops inside vta.func");
        }
    }

    //Terminator must be vta.finish.
    Operation *terminator = body.getTerminator();
    if (!isa<vta::FinishOp>(terminator)) {
        return terminator->emitOpError("expected vta.finish as terminator");
    }

    return success();
}

//===----------------------------------------------------------------------===//
// LoadOp
//===----------------------------------------------------------------------===//

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

    // Buffer bounds: SramBase + total elements must fit the SRAM depth.
    int64_t extent = (int64_t)(getYSize() + getYPad0() + getYPad1())
                   * (int64_t)(getXSize() + getXPad0() + getXPad1());
    int64_t depth;
    switch (getMemoryType()) {
        case 0: depth = 1 << VTA_LOG_UOP_BUFF_DEPTH; break;
        case 1: depth = 1 << VTA_LOG_WGT_BUFF_DEPTH; break;
        case 2: depth = 1 << VTA_LOG_INP_BUFF_DEPTH; break;
        case 3: depth = 1 << VTA_LOG_ACC_BUFF_DEPTH; break;
        default: return success();
    }
    if ((int64_t)getSramBase() + extent > depth)
        return emitOpError("load exceeds SRAM buffer bounds");

    return success();
}

//===----------------------------------------------------------------------===//
// StoreOp
//===----------------------------------------------------------------------===//

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

    // Buffer bounds on the OUT buffer.
    int64_t extent = (int64_t)(getYSize() + getYPad0() + getYPad1())
                   * (int64_t)(getXSize() + getXPad0() + getXPad1());
    int64_t depth = 1 << VTA_LOG_OUT_BUFF_DEPTH;
    if ((int64_t)getSramBase() + extent > depth)
        return emitOpError("store exceeds SRAM buffer bounds");

    return success();
}

//===----------------------------------------------------------------------===//
// GemmOp
//===----------------------------------------------------------------------===//

LogicalResult GemmOp::verify() {
    if (getUopBgn() > 127)
        return emitOpError("UopBgn must be 0-127");
    if (getUopBgn() > getUopEnd())
        return emitOpError("UopBgn must be <= UopEnd");
    if (!getResetReg() && getUopEnd() <= getUopBgn())
        return emitOpError("UopEnd must be > UopBgn when ResetReg is false");
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

//===----------------------------------------------------------------------===//
// AluOp
//===----------------------------------------------------------------------===//

LogicalResult AluOp::verify() {
    if (getUopBgn() > 127)
        return emitOpError("UopBgn must be 0-127");
    if (getUopBgn() > getUopEnd())
        return emitOpError("UopBgn must be <= UopEnd");
    if (!getResetReg() && getUopEnd() <= getUopBgn())
        return emitOpError("UopEnd must be > UopBgn when ResetReg is false");
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
    if (getUseImm() && getAluOpcode() == 4) {
        if (getImm() >= (1 << VTA_MUL_ARG_BIT_WIDTH))
            return emitOpError("MUL immediate must fit in 8 bits");
    }

    return success();
}

//===----------------------------------------------------------------------===//
// UcodeOp
//===----------------------------------------------------------------------===//

LogicalResult UcodeOp::verify() {
    if (getRecords().empty())
        return emitOpError("Records must not be empty");

    if (getRecords().size() > (size_t)(1 << VTA_LOG_UOP_BUFF_DEPTH))
        return emitOpError("ucode has more records than the UOP buffer can hold");

    //Each record is [dst, src, wgt], indexing into acc, inp, wgt respectively.
    for (Attribute a : getRecords()) {
        auto triple = a.dyn_cast<ArrayAttr>();
        if (!triple || triple.size() != 3)
            return emitOpError("each record must be a triple (dst, src, wgt)");

        int64_t dst = triple[0].cast<IntegerAttr>().getInt();
        int64_t src = triple[1].cast<IntegerAttr>().getInt();
        int64_t wgt = triple[2].cast<IntegerAttr>().getInt();

        if (dst < 0 || dst >= (1LL << VTA_LOG_ACC_BUFF_DEPTH))
            return emitOpError("ucode dst index out of range");
        if (src < 0 || src >= (1LL << VTA_LOG_INP_BUFF_DEPTH))
            return emitOpError("ucode src index out of range");
        if (wgt < 0 || wgt >= (1LL << VTA_LOG_WGT_BUFF_DEPTH))
            return emitOpError("ucode wgt index out of range");
    }
    return success();
}

//===----------------------------------------------------------------------===//
// LoadNoOp
//===----------------------------------------------------------------------===//

LogicalResult LoadNoOp::verify() {
    if (getPopPrevDep())
        return emitOpError("PopPrevDep has no effect on a load no-op");
    if (getPushPrevDep())
        return emitOpError("PushPrevDep has no effect on a load no-op");
    return success();
}

//===----------------------------------------------------------------------===//
// StoreNoOp
//===----------------------------------------------------------------------===//

LogicalResult StoreNoOp::verify() {
    if (getPopNextDep())
        return emitOpError("PopNextDep has no effect on a store no-op");
    if (getPushNextDep())
        return emitOpError("PushNextDep has no effect on a store no-op");
    return success();
}