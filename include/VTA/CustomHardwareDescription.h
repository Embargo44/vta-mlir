#ifndef VTA_CUSTOM_HARDWARE_DESCRIPTION_H
#define VTA_CUSTOM_HARDWARE_DESCRIPTION_H

#include <cstddef>
#include <cstdint>


// Hardware log-width macros.
// Source: config/vta_config.json in the TVM tree.
// Consumed by: the derived log-depth macros below. Must match TVM's build
//   exactly, or the instruction structs will be laid out differently.
#define VTA_LOG_ACC_BUFF_SIZE 17
#define VTA_LOG_ACC_WIDTH     5
#define VTA_LOG_BATCH         0
#define VTA_LOG_BLOCK         4
#define VTA_LOG_BLOCK_IN      4
#define VTA_LOG_BLOCK_OUT     4
#define VTA_LOG_BUS_WIDTH     6
#define VTA_LOG_INP_BUFF_SIZE 15
#define VTA_LOG_INP_WIDTH     3
#define VTA_LOG_OUT_BUFF_SIZE 15
#define VTA_LOG_OUT_WIDTH     3
#define VTA_LOG_UOP_BUFF_SIZE 15
#define VTA_LOG_UOP_WIDTH     5
#define VTA_LOG_WGT_BUFF_SIZE 18
#define VTA_LOG_WGT_WIDTH     3


//===----------------------------------------------------------------------===//
// Derived log-depth macros.
//
// Copied from vta/hw_spec_const.h. Used as bit-field widths in the
// instruction structs below. Must match the TVM build.
//===----------------------------------------------------------------------===//

#define VTA_LOG_UOP_BUFF_DEPTH \
    (VTA_LOG_UOP_BUFF_SIZE - VTA_LOG_UOP_WIDTH + 3)
#define VTA_LOG_WGT_BUFF_DEPTH \
    (VTA_LOG_WGT_BUFF_SIZE - VTA_LOG_BLOCK_OUT - VTA_LOG_BLOCK_IN - VTA_LOG_WGT_WIDTH + 3)
#define VTA_LOG_INP_BUFF_DEPTH \
    (VTA_LOG_INP_BUFF_SIZE - VTA_LOG_BATCH - VTA_LOG_BLOCK_IN - VTA_LOG_INP_WIDTH + 3)
#define VTA_LOG_ACC_BUFF_DEPTH \
    (VTA_LOG_ACC_BUFF_SIZE - VTA_LOG_BATCH - VTA_LOG_BLOCK_OUT - VTA_LOG_ACC_WIDTH + 3)

//===----------------------------------------------------------------------===//
// Instruction field widths.
//
// Copied from vta/hw_spec_const.h.
//===----------------------------------------------------------------------===//

#define VTA_OPCODE_BIT_WIDTH           3
#define VTA_ALU_OPCODE_BIT_WIDTH       3
#define VTA_MEMOP_ID_BIT_WIDTH         3
#define VTA_MEMOP_SRAM_ADDR_BIT_WIDTH  16
#define VTA_MEMOP_DRAM_ADDR_BIT_WIDTH  32
#define VTA_MEMOP_SIZE_BIT_WIDTH       16
#define VTA_MEMOP_STRIDE_BIT_WIDTH     16
#define VTA_MEMOP_PAD_BIT_WIDTH        4
#define VTA_ALUOP_IMM_BIT_WIDTH        16
#define VTA_LOOP_ITER_WIDTH            14
#define VTA_LOG_OUT_BUFF_DEPTH         15
#define VTA_MUL_ARG_BIT_WIDTH          8

//===----------------------------------------------------------------------===//
// Instruction structs.
//
// Copied from vta/hw_spec.h. Must stay bit-for-bit identical to what the
// TVM simulator library was compiled against: the translator memcpy's
// these directly into the binary, and the simulator reinterprets the
// same bytes.
//===----------------------------------------------------------------------===//

struct VTAGenericInsn {
    uint64_t opcode         : VTA_OPCODE_BIT_WIDTH;
    uint64_t pop_prev_dep   : 1;
    uint64_t pop_next_dep   : 1;
    uint64_t push_prev_dep  : 1;
    uint64_t push_next_dep  : 1;
    uint64_t pad_0          : 64 - VTA_OPCODE_BIT_WIDTH - 4;
    uint64_t pad_1          : 64;
};

struct VTAMemInsn {
    uint64_t opcode         : VTA_OPCODE_BIT_WIDTH;
    uint64_t pop_prev_dep   : 1;
    uint64_t pop_next_dep   : 1;
    uint64_t push_prev_dep  : 1;
    uint64_t push_next_dep  : 1;
    uint64_t memory_type    : VTA_MEMOP_ID_BIT_WIDTH;
    uint64_t sram_base      : VTA_MEMOP_SRAM_ADDR_BIT_WIDTH;
    uint64_t dram_base      : VTA_MEMOP_DRAM_ADDR_BIT_WIDTH;
    uint64_t y_size         : VTA_MEMOP_SIZE_BIT_WIDTH;
    uint64_t x_size         : VTA_MEMOP_SIZE_BIT_WIDTH;
    uint64_t x_stride       : VTA_MEMOP_STRIDE_BIT_WIDTH;
    uint64_t y_pad_0        : VTA_MEMOP_PAD_BIT_WIDTH;
    uint64_t y_pad_1        : VTA_MEMOP_PAD_BIT_WIDTH;
    uint64_t x_pad_0        : VTA_MEMOP_PAD_BIT_WIDTH;
    uint64_t x_pad_1        : VTA_MEMOP_PAD_BIT_WIDTH;
};

struct VTAGemInsn {
    uint64_t opcode         : VTA_OPCODE_BIT_WIDTH;
    uint64_t pop_prev_dep   : 1;
    uint64_t pop_next_dep   : 1;
    uint64_t push_prev_dep  : 1;
    uint64_t push_next_dep  : 1;
    uint64_t reset_reg      : 1;
    uint64_t uop_bgn        : VTA_LOG_UOP_BUFF_DEPTH;
    uint64_t uop_end        : VTA_LOG_UOP_BUFF_DEPTH + 1;
    uint64_t iter_out       : VTA_LOOP_ITER_WIDTH;
    uint64_t iter_in        : VTA_LOOP_ITER_WIDTH;
    uint64_t dst_factor_out : VTA_LOG_ACC_BUFF_DEPTH;
    uint64_t dst_factor_in  : VTA_LOG_ACC_BUFF_DEPTH;
    uint64_t src_factor_out : VTA_LOG_INP_BUFF_DEPTH;
    uint64_t src_factor_in  : VTA_LOG_INP_BUFF_DEPTH;
    uint64_t wgt_factor_out : VTA_LOG_WGT_BUFF_DEPTH;
    uint64_t wgt_factor_in  : VTA_LOG_WGT_BUFF_DEPTH;
};

struct VTAAluInsn {
    uint64_t opcode         : VTA_OPCODE_BIT_WIDTH;
    uint64_t pop_prev_dep   : 1;
    uint64_t pop_next_dep   : 1;
    uint64_t push_prev_dep  : 1;
    uint64_t push_next_dep  : 1;
    uint64_t reset_reg      : 1;
    uint64_t uop_bgn        : VTA_LOG_UOP_BUFF_DEPTH;
    uint64_t uop_end        : VTA_LOG_UOP_BUFF_DEPTH + 1;
    uint64_t iter_out       : VTA_LOOP_ITER_WIDTH;
    uint64_t iter_in        : VTA_LOOP_ITER_WIDTH;
    uint64_t dst_factor_out : VTA_LOG_ACC_BUFF_DEPTH;
    uint64_t dst_factor_in  : VTA_LOG_ACC_BUFF_DEPTH;
    uint64_t src_factor_out : VTA_LOG_ACC_BUFF_DEPTH;
    uint64_t src_factor_in  : VTA_LOG_ACC_BUFF_DEPTH;
    uint64_t alu_opcode     : VTA_ALU_OPCODE_BIT_WIDTH;
    uint64_t use_imm        : 1;
    int64_t  imm            : VTA_ALUOP_IMM_BIT_WIDTH;
};

struct VTAUop {
    uint32_t dst_idx        : VTA_LOG_ACC_BUFF_DEPTH;
    uint32_t src_idx        : (VTA_LOG_ACC_BUFF_DEPTH > VTA_LOG_INP_BUFF_DEPTH
                              ? VTA_LOG_ACC_BUFF_DEPTH
                              : VTA_LOG_INP_BUFF_DEPTH);
    uint32_t wgt_idx        : VTA_LOG_WGT_BUFF_DEPTH;
};



// Memory type IDs.
// Source: matches VTA_MEM_ID_* in vta/hw_spec.h.
// Consumed by: vta-translate.cpp (packing load/store), Passes.cpp (no-op
//   transform, dependency queue mapping), run_sim.cpp (element size lookup).
enum VtaMemoryType : uint8_t {
    VTA_MEM_UOP = 0,
    VTA_MEM_WGT = 1,
    VTA_MEM_INP = 2,
    VTA_MEM_ACC = 3,
    VTA_MEM_OUT = 4,
};



// Instruction opcodes.
// Source: matches VTA_OPCODE_* in vta/hw_spec.h.
// Consumed by: vta-translate.cpp (emitting instructions), run_sim.cpp
//   (deciding which instructions to address-translate).
enum VtaOpcode : uint8_t {
    VTA_OP_LOAD   = 0,
    VTA_OP_STORE  = 1,
    VTA_OP_GEMM   = 2,
    VTA_OP_FINISH = 3,
    VTA_OP_ALU    = 4,
};



// ALU opcode IDs.
// Source: matches VTA_ALU_OPCODE_* in vta/hw_spec.h.
// Consumed by: vta-translate.cpp (packing alu instructions).
enum VtaAluOpcode : uint8_t {
    VTA_ALU_MIN = 0,
    VTA_ALU_MAX = 1,
    VTA_ALU_ADD = 2,
    VTA_ALU_SHR = 3,
    VTA_ALU_MUL = 4,
};



// Bytes per element, per SRAM.
// Source: derived from the log-width macros above, written out explicitly.
// Consumed by: run_sim.cpp (dram_base translation), vta-translate.cpp
//   (writing addresses), Passes.cpp (no-op transform sizing).
static constexpr size_t VTA_UOP_ELEM_BYTES = 4;
static constexpr size_t VTA_INP_ELEM_BYTES = 16;
static constexpr size_t VTA_WGT_ELEM_BYTES = 256;
static constexpr size_t VTA_ACC_ELEM_BYTES = 64;
static constexpr size_t VTA_OUT_ELEM_BYTES = 16;



// DRAM layout convention.
// Source: project decision (not from TVM).
// Consumed by: vta-translate.cpp (writing .mlir addresses),
//   run_sim.cpp (placing fixtures and translating dram_base), the .mlir
//   test files (they write these addresses directly).
//
// IMPORTANT: the data offsets below are ELEMENT indices, not byte offsets.
// The simulator multiplies by the element size of the target memory to get
// a byte address. The .mlir dram values use the same element indices.
static constexpr size_t VTA_REGION_SIZE = 1024 * 1024;  // 1 MB
static constexpr size_t VTA_INSN_OFFSET = VTA_REGION_SIZE - 0x1000;  // byte offset

//Size of fixture data planted in run_sim, in bytes.
static constexpr size_t VTA_INPUT_SIZE = 64;

//Byte addresses these resolve to:
//  ucode   elem 0     -> byte 0
//  inp     elem 4096  -> byte 65536
//  wgt     elem 512   -> byte 131072
//  out     elem 16384 -> byte 262144
static constexpr size_t VTA_UCODE_ELEM_OFFSET  = 0;
static constexpr size_t VTA_INPUT_ELEM_OFFSET  = 4096;
static constexpr size_t VTA_WEIGHT_ELEM_OFFSET = 512;
static constexpr size_t VTA_OUTPUT_ELEM_OFFSET = 16384;



// Binary format constants.
// Source: project decision.
// Consumed by: vta-translate.cpp (writing the header and instruction
//   records), run_sim.cpp (splitting the file).
static constexpr size_t VTA_HEADER_BYTES       = 4;
static constexpr size_t VTA_INSN_BYTES         = 16;
static constexpr size_t VTA_UCODE_RECORD_BYTES = 4;


// Ucode load instruction defaults.
// Source: project decision.
// Consumed by: Passes.cpp (TransformUcodeToLoadOpPass), run_sim.cpp
//   (knows where the ucode lives in DRAM).
static constexpr uint8_t  VTA_UCODE_LOAD_MEMTYPE = VTA_MEM_UOP;
static constexpr uint32_t VTA_UCODE_LOAD_DRAM    = 0;



// Simulator cycle budget.
// Source: project decision.
// Consumed by: run_sim.cpp (argument to VTADeviceRun).
static constexpr int VTA_MAX_CYCLES = 10000000;

#endif // VTA_CUSTOM_HARDWARE_DESCRIPTION_H