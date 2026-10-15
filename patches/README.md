File: `3rdparty/vta-hw/src/sim/sim_tlpp.cc` in the TVM tree.
Line: ~153, inside `TlppVerify::CoreRun`.

### Before

    done_ = GetOperationCode(insn) == VTA_OPCODE_FINISH;

### After

    if (GetOperationCode(insn) == VTA_OPCODE_FINISH) done_ = 1;