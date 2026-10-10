// run_sim.cpp — load the VTA binary produced by vta-translate and run it.


// To build:
//   g++ -std=c++17 -O2 run_sim.cpp -o run_sim \
//     -I"$TVM_HOME/3rdparty/vta-hw/include" \
//     -I"$TVM_HOME/3rdparty/vta-hw/src" \
//     -I"$TVM_HOME/include" \
//     -I"$VTA_MLIR_HOME/include" \
//     -L"$TVM_HOME/build" -lvta_fsim -ltvm_runtime \
//     -Wl,-rpath,"$TVM_HOME/build"
//
// Or run ./build_run_sim.sh in the project root, which does the same thing.
//
// TVM_HOME defaults to $HOME/tvm. Set it if your TVM checkout is elsewhere.


#include "VTA/CustomHardwareDescription.h"
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <vector>

#include "vta/driver.h"


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

    std::vector<uint8_t> file_bytes((std::istreambuf_iterator<char>(f)),
                                     std::istreambuf_iterator<char>());
    std::printf("loaded %zu bytes total\n", file_bytes.size());

    uint32_t insn_len;
    std::memcpy(&insn_len, file_bytes.data(), 4);

    const uint8_t *insn_start  = file_bytes.data() + VTA_HEADER_BYTES;
    const uint8_t *ucode_start = file_bytes.data() + VTA_HEADER_BYTES + insn_len;
    size_t ucode_len = file_bytes.size() - VTA_HEADER_BYTES - insn_len;
    uint32_t insn_count = insn_len / VTA_INSN_BYTES;

    std::printf("instruction bytes: %u\n", insn_len);
    std::printf("microcode bytes:   %zu\n", ucode_len);

    std::vector<uint8_t> dram_image(VTA_REGION_SIZE, 0);
    std::memcpy(dram_image.data() + VTA_INSN_OFFSET, insn_start, insn_len);
    if (ucode_len > 0)
        std::memcpy(dram_image.data() + VTA_UCODE_OFFSET, ucode_start, ucode_len);

    for (size_t i = 0; i < VTA_INPUT_SIZE; i++)
        dram_image[VTA_INPUT_OFFSET + i] = (uint8_t)(i + 1);

    for (size_t i = 0; i < VTA_INPUT_SIZE; i++)
        dram_image[VTA_WEIGHT_OFFSET + i] = (uint8_t)(0x10 + i);

    VTADeviceHandle dev = VTADeviceAlloc();

    void *region = VTAMemAlloc(VTA_REGION_SIZE, VTA_NOT_CACHED);

    vta_phy_addr_t base_phy = VTAMemGetPhyAddr(region);
    vta_phy_addr_t insn_phy = base_phy + VTA_INSN_OFFSET;
    std::printf("region phys = 0x%x\n", base_phy);
    std::printf("insn   phys = 0x%x\n", insn_phy);

    {
        VTAMemInsn *arr = (VTAMemInsn *)(dram_image.data() + VTA_INSN_OFFSET);
        for (uint32_t i = 0; i < insn_count; i++) {
            if (arr[i].opcode != VTA_OP_LOAD &&
                arr[i].opcode != VTA_OP_STORE)
                continue;

            size_t elem_bytes = 1;
            switch (arr[i].memory_type) {
                case VTA_MEM_UOP: elem_bytes = VTA_UOP_ELEM_BYTES; break;
                case VTA_MEM_WGT: elem_bytes = VTA_WGT_ELEM_BYTES; break;
                case VTA_MEM_INP: elem_bytes = VTA_INP_ELEM_BYTES; break;
                case VTA_MEM_ACC: elem_bytes = VTA_ACC_ELEM_BYTES; break;
                case VTA_MEM_OUT: elem_bytes = VTA_OUT_ELEM_BYTES; break;
                default: continue;
            }

            uint64_t addr_bytes = (uint64_t)arr[i].dram_base + base_phy;
            arr[i].dram_base = (uint32_t)(addr_bytes / elem_bytes);
        }
    }

    VTAMemCopyFromHost(region, dram_image.data(), VTA_REGION_SIZE);

    std::printf("running %u instructions...\n", insn_count);
    int rc = VTADeviceRun(dev, insn_phy, insn_count, VTA_MAX_CYCLES);
    std::printf("VTADeviceRun returned %d\n", rc);

    std::vector<uint8_t> output(VTA_INPUT_SIZE);
    VTAMemCopyToHost(output.data(),
                     (uint8_t *)region + VTA_OUTPUT_OFFSET,
                     output.size());
    std::printf("output bytes at offset 0x%zx:\n", VTA_OUTPUT_OFFSET);
    for (size_t i = 0; i < output.size(); i++) {
        std::printf("%02x ", output[i]);
        if ((i + 1) % 16 == 0) std::printf("\n");
    }
    std::printf("\n");

    VTAMemFree(region);
    VTADeviceFree(dev);
    return 0;
}



/*

cd ~/vta-mlir
g++ -std=c++17 -O2 run_sim.cpp -o run_sim \
  -I"$HOME/tvm/3rdparty/vta-hw/include" \
  -I"$HOME/tvm/3rdparty/vta-hw/src" \
  -I"$HOME/tvm/include" \
  -I"$HOME/vta-mlir/include" \
  -L"$HOME/tvm/build" -lvta_fsim -ltvm_runtime \
  -Wl,-rpath,"$HOME/tvm/build"
echo "build: $?"




~/vta-mlir/build/bin/vta-translate ~/Desktop/test.mlir --vta-binary -o ~/Desktop/out.bin
~/vta-mlir/run_sim ~/Desktop/out.bin






*/



