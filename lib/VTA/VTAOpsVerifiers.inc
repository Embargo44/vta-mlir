//Verifier implementations. Fills in verify() declared by VTAOps.td.

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                 SHARED VERIFICATION Methods
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Resolve an SSA constant operand; otherwise use the literal attribute value.
static int64_t getArithConstantValue(Value operand) {
    Operation *constantOp = operand.getDefiningOp();
    return constantOp->getAttrOfType<IntegerAttr>("value").getInt();
}

template <typename T>
static int64_t getFieldValue(Value operand, llvm::Optional<T> attributeValue) {
    return operand ? getArithConstantValue(operand)
                   : static_cast<int64_t>(attributeValue.value_or(0));
}

static LogicalResult verifyLoad(LoadOpInterface load) {
    Operation *op = load.getOperation();

    if (load.getMemoryType() > 3)
        return op->emitOpError("MemoryType must be 0-3 (UOP, WGT, INP, ACC)");
    if (getFieldValue(load.getYPad0Operand(), load.getYPad0()) > 15)
        return op->emitOpError("YPad0 must be 0-15");
    if (getFieldValue(load.getYPad1Operand(), load.getYPad1()) > 15)
        return op->emitOpError("YPad1 must be 0-15");
    if (getFieldValue(load.getXPad0Operand(), load.getXPad0()) > 15)
        return op->emitOpError("XPad0 must be 0-15");
    if (getFieldValue(load.getXPad1Operand(), load.getXPad1()) > 15)
        return op->emitOpError("XPad1 must be 0-15");

    // Buffer bounds: SramBase + total elements must fit the SRAM depth.
    int64_t extent = (getFieldValue(load.getYSizeOperand(), load.getYSize())
                      + getFieldValue(load.getYPad0Operand(), load.getYPad0())
                      + getFieldValue(load.getYPad1Operand(), load.getYPad1()))
                   * (getFieldValue(load.getXSizeOperand(), load.getXSize())
                      + getFieldValue(load.getXPad0Operand(), load.getXPad0())
                      + getFieldValue(load.getXPad1Operand(), load.getXPad1()));
    int64_t depth;
    switch (load.getMemoryType()) {
        case 0: depth = 1 << VTA_LOG_UOP_BUFF_DEPTH; break;
        case 1: depth = 1 << VTA_LOG_WGT_BUFF_DEPTH; break;
        case 2: depth = 1 << VTA_LOG_INP_BUFF_DEPTH; break;
        case 3: depth = 1 << VTA_LOG_ACC_BUFF_DEPTH; break;
        default: return success();
    }
    if (getFieldValue(load.getSramBaseOperand(), load.getSramBase()) + extent > depth)
        return op->emitOpError("load exceeds SRAM buffer bounds");

    return success();
}

static LogicalResult verifyStore(StoreOpInterface store) {
    Operation *op = store.getOperation();

    if (store.getMemoryType() != 4)
        return op->emitOpError("MemoryType must be 4 (OUT)");
    if (getFieldValue(store.getYPad0Operand(), store.getYPad0()) > 15)
        return op->emitOpError("YPad0 must be 0-15");
    if (getFieldValue(store.getYPad1Operand(), store.getYPad1()) > 15)
        return op->emitOpError("YPad1 must be 0-15");
    if (getFieldValue(store.getXPad0Operand(), store.getXPad0()) > 15)
        return op->emitOpError("XPad0 must be 0-15");
    if (getFieldValue(store.getXPad1Operand(), store.getXPad1()) > 15)
        return op->emitOpError("XPad1 must be 0-15");

    // Buffer bounds on the OUT buffer.
    int64_t extent = (getFieldValue(store.getYSizeOperand(), store.getYSize())
                      + getFieldValue(store.getYPad0Operand(), store.getYPad0())
                      + getFieldValue(store.getYPad1Operand(), store.getYPad1()))
                   * (getFieldValue(store.getXSizeOperand(), store.getXSize())
                      + getFieldValue(store.getXPad0Operand(), store.getXPad0())
                      + getFieldValue(store.getXPad1Operand(), store.getXPad1()));
    int64_t depth = 1 << VTA_LOG_OUT_BUFF_DEPTH;
    if (getFieldValue(store.getSramBaseOperand(), store.getSramBase()) + extent > depth)
        return op->emitOpError("store exceeds SRAM buffer bounds");

    return success();
}

static LogicalResult verifyGemm(GemmOpInterface gemm) {
    Operation *op = gemm.getOperation();

    if (getFieldValue(gemm.getUopBgnOperand(), gemm.getUopBgn()) > 127)
        return op->emitOpError("UopBgn must be 0-127");
    if (getFieldValue(gemm.getUopBgnOperand(), gemm.getUopBgn()) >
        getFieldValue(gemm.getUopEndOperand(), gemm.getUopEnd()))
        return op->emitOpError("UopBgn must be <= UopEnd");
    if (!gemm.getResetReg() &&
        getFieldValue(gemm.getUopEndOperand(), gemm.getUopEnd()) <=
        getFieldValue(gemm.getUopBgnOperand(), gemm.getUopBgn()))
        return op->emitOpError("UopEnd must be > UopBgn when ResetReg is false");
    if (getFieldValue(gemm.getIterOutOperand(), gemm.getIterOut()) < 1)
        return op->emitOpError("IterOut must be >= 1");
    if (getFieldValue(gemm.getIterInOperand(), gemm.getIterIn()) < 1)
        return op->emitOpError("IterIn must be >= 1");
    if (getFieldValue(gemm.getIterOutOperand(), gemm.getIterOut()) > 16383)
        return op->emitOpError("IterOut must be <= 16383");
    if (getFieldValue(gemm.getIterInOperand(), gemm.getIterIn()) > 16383)
        return op->emitOpError("IterIn must be <= 16383");
    if (getFieldValue(gemm.getDstFactorOutOperand(), gemm.getDstFactorOut()) > 127)
        return op->emitOpError("DstFactorOut must be 0-127");
    if (getFieldValue(gemm.getDstFactorInOperand(), gemm.getDstFactorIn()) > 127)
        return op->emitOpError("DstFactorIn must be 0-127");
    if (getFieldValue(gemm.getSrcFactorOutOperand(), gemm.getSrcFactorOut()) > 127)
        return op->emitOpError("SrcFactorOut must be 0-127");
    if (getFieldValue(gemm.getSrcFactorInOperand(), gemm.getSrcFactorIn()) > 127)
        return op->emitOpError("SrcFactorIn must be 0-127");
    if (getFieldValue(gemm.getWgtFactorOutOperand(), gemm.getWgtFactorOut()) > 127)
        return op->emitOpError("WgtFactorOut must be 0-127");
    if (getFieldValue(gemm.getWgtFactorInOperand(), gemm.getWgtFactorIn()) > 127)
        return op->emitOpError("WgtFactorIn must be 0-127");

    return success();
}

static LogicalResult verifyAlu(AluOpInterface alu) {
    Operation *op = alu.getOperation();

    if (getFieldValue(alu.getUopBgnOperand(), alu.getUopBgn()) > 127)
        return op->emitOpError("UopBgn must be 0-127");
    if (getFieldValue(alu.getUopBgnOperand(), alu.getUopBgn()) >
        getFieldValue(alu.getUopEndOperand(), alu.getUopEnd()))
        return op->emitOpError("UopBgn must be <= UopEnd");
    if (!alu.getResetReg() &&
        getFieldValue(alu.getUopEndOperand(), alu.getUopEnd()) <=
        getFieldValue(alu.getUopBgnOperand(), alu.getUopBgn()))
        return op->emitOpError("UopEnd must be > UopBgn when ResetReg is false");
    if (getFieldValue(alu.getIterOutOperand(), alu.getIterOut()) < 1)
        return op->emitOpError("IterOut must be >= 1");
    if (getFieldValue(alu.getIterInOperand(), alu.getIterIn()) < 1)
        return op->emitOpError("IterIn must be >= 1");
    if (getFieldValue(alu.getIterOutOperand(), alu.getIterOut()) > 16383)
        return op->emitOpError("IterOut must be <= 16383");
    if (getFieldValue(alu.getIterInOperand(), alu.getIterIn()) > 16383)
        return op->emitOpError("IterIn must be <= 16383");
    if (getFieldValue(alu.getDstFactorOutOperand(), alu.getDstFactorOut()) > 127)
        return op->emitOpError("DstFactorOut must be 0-127");
    if (getFieldValue(alu.getDstFactorInOperand(), alu.getDstFactorIn()) > 127)
        return op->emitOpError("DstFactorIn must be 0-127");
    if (getFieldValue(alu.getSrcFactorOutOperand(), alu.getSrcFactorOut()) > 127)
        return op->emitOpError("SrcFactorOut must be 0-127");
    if (getFieldValue(alu.getSrcFactorInOperand(), alu.getSrcFactorIn()) > 127)
        return op->emitOpError("SrcFactorIn must be 0-127");
    if (alu.getAluOpcode() > 4)
        return op->emitOpError("AluOpcode must be 0-4 (MIN, MAX, ADD, SHR, MUL)");

    //    if (alu.getUseImm() && alu.getAluOpcode() == 4) {
    //    if (alu.getImm() >= (1 << VTA_MUL_ARG_BIT_WIDTH))
    //        return op->emitOpError("MUL immediate must fit in 8 bits");}

    return success();
}










//////////////////////////////////////////////////////////////////////////////////////////////
//                                   Other Verification Methods
//////////////////////////////////////////////////////////////////////////////////////////////

// FuncOp
LogicalResult FuncOp::verify() {
    //Body must not be empty. At minimum a vta.finish terminator.
    Block &body = getBody().front();
    if (body.empty()) {
        return emitOpError("function body must not be empty");
    }

    //Every op in the body must be a VTA op (except the terminator, which
    //is vta.finish and is also a VTA op).
    // Every operation must belong to either the VTA or arith dialect.
    for (Operation &op : body) {
        Dialect *dialect = op.getDialect();

        if (dialect != getOperation()->getDialect() &&
            dialect->getNamespace() != "arith") {
            return op.emitOpError(
                "expected only VTA or arith ops inside vta.func");
        }
    }

    //Terminator must be vta.finish.
    Operation *terminator = body.getTerminator();
    if (!isa<vta::FinishOp>(terminator)) {
        return terminator->emitOpError("expected vta.finish as terminator");
    }

    return success();
}

// UcodeOp
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






//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                 LoadOP CUSTOM
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

LogicalResult LoadNoOp::verify() {
    return verifyLoad(*this);
}

LogicalResult LoadUOPOp::verify() {
    return verifyLoad(*this);
}

LogicalResult LoadWGTOp::verify() {
    return verifyLoad(*this);
}

LogicalResult LoadINPOp::verify() {
    return verifyLoad(*this);
}

LogicalResult LoadACCOp::verify() {
    return verifyLoad(*this);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                 StoreOP CUSTOM
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////



LogicalResult StoreOUTOp::verify() {
    return verifyStore(*this);
}

LogicalResult StoreNoOp::verify() {
    return verifyStore(*this);
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                ALU OP CUSTOM
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


LogicalResult AluMinImmOp::verify() {
    return verifyAlu(*this);
}

LogicalResult AluMaxImmOp::verify() {
    return verifyAlu(*this);
}

LogicalResult AluAddImmOp::verify() {
    return verifyAlu(*this);
}

LogicalResult AluShfImmOp::verify() {
    return verifyAlu(*this);
}

LogicalResult AluMulImmOp::verify() {
    return verifyAlu(*this);
}

LogicalResult AluMinOp::verify() {
    return verifyAlu(*this);
}

LogicalResult AluMaxOp::verify() {
    return verifyAlu(*this);
}

LogicalResult AluAddOp::verify() {
    return verifyAlu(*this);
}

LogicalResult AluShfOp::verify() {
    return verifyAlu(*this);
    
}

LogicalResult AluMulOp::verify() {
    return verifyAlu(*this);
    
}

LogicalResult AluNoOp::verify() {
    return verifyAlu(*this);
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                 GemmOP CUSTOM
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

LogicalResult GemmResetOp::verify() {
    return verifyGemm(*this);
}

LogicalResult GemmNoResetOp::verify() {
    return verifyGemm(*this);
}

LogicalResult GemmNoOp::verify() {
    return verifyGemm(*this);
}










//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                 Old OP VERIFIERS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

LogicalResult LoadOp::verify() {
    return verifyLoad(*this);
}

LogicalResult StoreOp::verify() {
    return verifyStore(*this);
}

LogicalResult AluOp::verify() {
    //return verifyAlu(*this);
    return success();
}

LogicalResult GemmOp::verify() {
    return verifyGemm(*this);
}




