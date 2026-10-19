# Patches

Apply after `git submodule update --init --recursive`, before building TVM.

## sim_tlpp_done_fix.patch

File: `3rdparty/tvm/3rdparty/vta-hw/src/sim/sim_tlpp.cc`
Line: ~153, inside `TlppVerify::CoreRun`.

Before: `done_ = GetOperationCode(insn) == VTA_OPCODE_FINISH;`
After:  `if (GetOperationCode(insn) == VTA_OPCODE_FINISH) done_ = 1;`

The original assigns on every instruction, so any LOAD or STORE after
FINISH clears `done_` and the dispatch loop never exits.

Apply:

    cd 3rdparty/tvm/3rdparty/vta-hw
    git apply ../../../../patches/sim_tlpp_done_fix.patch
