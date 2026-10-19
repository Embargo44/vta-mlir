// run_sim.cpp — load the VTA binary produced by vta-translate and run it.


// To build:
//   g++ -std=c++17 -O2 run_sim.cpp -o run_sim \
//     -I"$VTA_MLIR_HOME/3rdparty/tvm/3rdparty/vta-hw/include" \
//     -I"$VTA_MLIR_HOME/3rdparty/tvm/3rdparty/vta-hw/src" \
//     -I"$VTA_MLIR_HOME/3rdparty/tvm/include" \
//     -I"$VTA_MLIR_HOME/include" \
//     -L"$VTA_MLIR_HOME/3rdparty/tvm/build" -lvta_fsim -ltvm_runtime \
//     -Wl,-rpath,"$VTA_MLIR_HOME/3rdparty/tvm/build"
//
// Or run ./build_run_sim.sh in the project root, which does the same thing.
//
//TVM is vendored as a git submodule under 3rdparty/tvm.




#include "VTA/CustomHardwareDescription.h"

//Just C++
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <vector>

//TVM simulator API. Points at TVM vta-hw include, not CustomHardwareDescription.h.
#include "vta/driver.h"


//Reads the binary produced by vta-translate, places it in the simulator's DRAM region, translates addresses, runs it, and prints the output block.
int main(int argc, char **argv) {
    if (argc != 2) {
        std::fprintf(stderr, "usage: %s <binary-file>\n", argv[0]);
        return 1;
    }
    std::ifstream f(argv[1], std::ios::binary);
    if (!f) {
        std::fprintf(stderr, "cannot open %s\n", argv[1]);
        return 1;
    }

    //Put the whole file into memory. Format is defined by vta-translate.
    std::vector<uint8_t> file_bytes((std::istreambuf_iterator<char>(f)),
                                     std::istreambuf_iterator<char>());
    std::printf("loaded %zu bytes total\n", file_bytes.size());

    //Split the file: [4-byte insn_len][insn region][ucode region].
    //Same layout the translator writes at the bottom of translateVTAtoBit.
    uint32_t insn_len;
    std::memcpy(&insn_len, file_bytes.data(), 4);

    const uint8_t *insn_start  = file_bytes.data() + VTA_HEADER_BYTES;
    const uint8_t *ucode_start = file_bytes.data() + VTA_HEADER_BYTES + insn_len;
    size_t ucode_len = file_bytes.size() - VTA_HEADER_BYTES - insn_len;
    uint32_t insn_count = insn_len / VTA_INSN_BYTES;

    std::printf("instruction bytes: %u\n", insn_len);
    std::printf("microcode bytes:   %zu\n", ucode_len);

    //Place instructions and ucode at the offsets the compiler assumed.
    //Insn offset is in bytes. Data offsets are in elements; multiply by
    //element size to get byte positions.
    std::vector<uint8_t> dram_image(VTA_REGION_SIZE, 0);
    std::memcpy(dram_image.data() + VTA_INSN_OFFSET, insn_start, insn_len);
    if (ucode_len > 0)
        std::memcpy(dram_image.data() + VTA_UCODE_ELEM_OFFSET * VTA_UOP_ELEM_BYTES,
                    ucode_start, ucode_len);

    //Test fixtures.  just bytes for loads to read.
    //Offsets are element indices; multiply by element size to get byte position.
    for (size_t i = 0; i < VTA_INPUT_SIZE; i++)
        dram_image[VTA_INPUT_ELEM_OFFSET * VTA_INP_ELEM_BYTES + i] = (uint8_t)(i + 1);

    for (size_t i = 0; i < VTA_INPUT_SIZE; i++)
        dram_image[VTA_WEIGHT_ELEM_OFFSET * VTA_WGT_ELEM_BYTES + i] = (uint8_t)(0x10 + i);

    //Allocate the simulator device and its DRAM region.
    VTADeviceHandle dev = VTADeviceAlloc();

    void *region = VTAMemAlloc(VTA_REGION_SIZE, VTA_NOT_CACHED);

    vta_phy_addr_t base_phy = VTAMemGetPhyAddr(region);
    vta_phy_addr_t insn_phy = base_phy + VTA_INSN_OFFSET;
    std::printf("region phys = 0x%x\n", base_phy);
    std::printf("insn   phys = 0x%x\n", insn_phy);

    //Add base_phy to every load/store dram_base.
    {
        VTAMemInsn *arr = (VTAMemInsn *)(dram_image.data() + VTA_INSN_OFFSET);
        for (uint32_t i = 0; i < insn_count; i++) {
            if (arr[i].opcode != VTA_OP_LOAD &&
                arr[i].opcode != VTA_OP_STORE)
                continue;

            //Element size depends on the target SRAM. VTA_UOP_ELEM_BYTES come from CustomHardwareDescription.h.
            size_t elem_bytes = 1;
            switch (arr[i].memory_type) {
                case VTA_MEM_UOP: elem_bytes = VTA_UOP_ELEM_BYTES; break;
                case VTA_MEM_WGT: elem_bytes = VTA_WGT_ELEM_BYTES; break;
                case VTA_MEM_INP: elem_bytes = VTA_INP_ELEM_BYTES; break;
                case VTA_MEM_ACC: elem_bytes = VTA_ACC_ELEM_BYTES; break;
                case VTA_MEM_OUT: elem_bytes = VTA_OUT_ELEM_BYTES; break;
                default: continue;
            }

            uint64_t addr_bytes = (uint64_t)arr[i].dram_base * elem_bytes + base_phy;
            arr[i].dram_base = (uint32_t)(addr_bytes / elem_bytes);
        }
    }




    //Copy the whole host-side image into the simulator's DRAM region.
    VTAMemCopyFromHost(region, dram_image.data(), VTA_REGION_SIZE);

    //Hand off to the simulator's TLPP dispatch loop. runs until FINISH
    std::printf("running %u instructions...\n", insn_count);
    int rc = VTADeviceRun(dev, insn_phy, insn_count, VTA_MAX_CYCLES);
    std::printf("VTADeviceRun returned %d\n", rc);

    //Read back the output region and print it.
    //Offset is element index; multiply by element size to get byte position.
    size_t out_byte_offset = VTA_OUTPUT_ELEM_OFFSET * VTA_OUT_ELEM_BYTES;
    std::vector<uint8_t> output(VTA_INPUT_SIZE);
    VTAMemCopyToHost(output.data(),
                     (uint8_t *)region + out_byte_offset,
                     output.size());
    std::printf("output bytes at offset 0x%zx:\n", out_byte_offset);
    for (size_t i = 0; i < output.size(); i++) {
        std::printf("%02x ", output[i]);
        if ((i + 1) % 16 == 0) std::printf("\n");
    }
    std::printf("\n");

    //Cleanup. Region first, then device.
    VTAMemFree(region);
    VTADeviceFree(dev);
    return 0;
}



