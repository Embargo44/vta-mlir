#ifndef VTA_CUSTOM_HARDWARE_DESCRIPTION_H
#define VTA_CUSTOM_HARDWARE_DESCRIPTION_H

#include <cstddef>
#include <cstdint>


// Hardware log-width macros.
// Source: config/vta_config.json in the TVM tree.
// Must be defined before hw_spec.h is included, because hw_spec_const.h
// uses them. Must match TVM's build exactly.
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

//OUT buffer depth. Not defined by TVM's hw_spec_const.h.
#define VTA_LOG_OUT_BUFF_DEPTH \
    (VTA_LOG_OUT_BUFF_SIZE - VTA_LOG_OUT_WIDTH + 3)




// TVM's VTA hardware spec: instruction structs, bit widths, element sizes,
// memory type IDs, opcodes. Vendored at 3rdparty/tvm/3rdparty/vta-hw.
#include "vta/hw_spec.h"


// Project aliases for TVM's memory type IDs.
enum VtaMemoryType : uint8_t {
    VTA_MEM_UOP = VTA_MEM_ID_UOP,
    VTA_MEM_WGT = VTA_MEM_ID_WGT,
    VTA_MEM_INP = VTA_MEM_ID_INP,
    VTA_MEM_ACC = VTA_MEM_ID_ACC,
    VTA_MEM_OUT = VTA_MEM_ID_OUT,
};

// Project aliases for TVM's instruction opcodes.
enum VtaOpcode : uint8_t {
    VTA_OP_LOAD   = VTA_OPCODE_LOAD,
    VTA_OP_STORE  = VTA_OPCODE_STORE,
    VTA_OP_GEMM   = VTA_OPCODE_GEMM,
    VTA_OP_FINISH = VTA_OPCODE_FINISH,
    VTA_OP_ALU    = VTA_OPCODE_ALU,
};

// Project aliases for TVM's ALU opcodes.
enum VtaAluOpcode : uint8_t {
    VTA_ALU_MIN = VTA_ALU_OPCODE_MIN,
    VTA_ALU_MAX = VTA_ALU_OPCODE_MAX,
    VTA_ALU_ADD = VTA_ALU_OPCODE_ADD,
    VTA_ALU_SHR = VTA_ALU_OPCODE_SHR,
    VTA_ALU_MUL = VTA_ALU_OPCODE_MUL,
};


// DRAM layout convention.
// Source: project decision (not from TVM).
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
static constexpr size_t VTA_HEADER_BYTES       = 4;
static constexpr size_t VTA_INSN_BYTES         = 16;
static constexpr size_t VTA_UCODE_RECORD_BYTES = 4;


// Ucode load instruction defaults.
// Source: project decision.
static constexpr uint8_t  VTA_UCODE_LOAD_MEMTYPE = VTA_MEM_UOP;
static constexpr uint32_t VTA_UCODE_LOAD_DRAM    = 0;



// Simulator cycle budget.
// Source: project decision.
static constexpr int VTA_MAX_CYCLES = 10000000;

#endif // VTA_CUSTOM_HARDWARE_DESCRIPTION_H