#include "VTA/CustomHardwareDescription.h"
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>
#include "vta/driver.h"

int main(int argc, char **argv) {
    if (argc != 3) {
        std::fprintf(stderr, "usage: %s <binary-file> <data-file>\n", argv[0]);
        return 1;
    }
    std::ifstream f(argv[1], std::ios::binary);
    if (!f) { std::fprintf(stderr, "cannot open %s\n", argv[1]); return 1; }

    std::ifstream data_f(argv[2]);
    if (!data_f) { std::fprintf(stderr, "cannot open %s\n", argv[2]); return 1; }

    // Read binary
    std::vector<uint8_t> file_bytes((std::istreambuf_iterator<char>(f)),
                                     std::istreambuf_iterator<char>());
    uint32_t insn_len;
    std::memcpy(&insn_len, file_bytes.data(), VTA_HEADER_BYTES);

    const uint8_t *insn_start  = file_bytes.data() + VTA_HEADER_BYTES;
    const uint8_t *ucode_start = file_bytes.data() + VTA_HEADER_BYTES + insn_len;
    size_t ucode_len = file_bytes.size() - VTA_HEADER_BYTES - insn_len;
    uint32_t insn_count = insn_len / VTA_INSN_BYTES;

    std::vector<uint8_t> dram_image(VTA_REGION_SIZE, 0);
    std::memcpy(dram_image.data() + VTA_INSN_OFFSET, insn_start, insn_len);
    if (ucode_len > 0)
        std::memcpy(dram_image.data() + VTA_UCODE_ELEM_OFFSET * VTA_UOP_ELEM_BYTES, ucode_start, ucode_len);

    // Parse data file and inject into DRAM
    std::string line;
    int bytes_injected = 0;
    while (std::getline(data_f, line)) {
        size_t comment_pos = line.find('#');
        if (comment_pos != std::string::npos) line = line.substr(0, comment_pos);
        if (line.empty()) continue;

        std::stringstream ss(line);
        std::string addr_str, val_str;
        if (!(ss >> addr_str >> val_str)) continue;

        uint32_t addr = std::stoul(addr_str, nullptr, 16);
        uint8_t val = (uint8_t)std::stoul(val_str, nullptr, 16);

        if (addr < VTA_REGION_SIZE) {
            dram_image[addr] = val;
            bytes_injected++;
        }
    }
    std::printf("Injected %d bytes into DRAM from data file.\n", bytes_injected);

    // Allocate device and run
    VTADeviceHandle dev = VTADeviceAlloc();
    void *region = VTAMemAlloc(VTA_REGION_SIZE, VTA_NOT_CACHED);
    vta_phy_addr_t base_phy = VTAMemGetPhyAddr(region);
    vta_phy_addr_t insn_phy = base_phy + VTA_INSN_OFFSET;

    // Patch addresses
    VTAMemInsn *arr = (VTAMemInsn *)(dram_image.data() + VTA_INSN_OFFSET);
    for (uint32_t i = 0; i < insn_count; i++) {
        if (arr[i].opcode != VTA_OP_LOAD && arr[i].opcode != VTA_OP_STORE) continue;
        size_t elem_bytes = 1;
        switch (arr[i].memory_type) {
            case 0: elem_bytes = VTA_UOP_ELEM_BYTES; break;
            case 1: elem_bytes = VTA_WGT_ELEM_BYTES; break;
            case 2: elem_bytes = VTA_INP_ELEM_BYTES; break;
            case 3: elem_bytes = VTA_ACC_ELEM_BYTES; break;
            case 4: elem_bytes = VTA_OUT_ELEM_BYTES; break;
            default: continue;
        }
        uint64_t addr_bytes = (uint64_t)arr[i].dram_base * elem_bytes + base_phy;
        arr[i].dram_base = (uint32_t)(addr_bytes / elem_bytes);
    }

    VTAMemCopyFromHost(region, dram_image.data(), VTA_REGION_SIZE);
    int rc = VTADeviceRun(dev, insn_phy, insn_count, VTA_MAX_CYCLES);
    
    size_t out_byte_offset = 16384 * VTA_OUT_ELEM_BYTES;
    std::vector<uint8_t> output(64);
    VTAMemCopyToHost(output.data(), (uint8_t *)region + out_byte_offset, output.size());

    std::printf("VTADeviceRun returned %d\n", rc);
    std::printf("Output bytes:\n");
    for (size_t i = 0; i < output.size(); i++) {
        std::printf("%02x ", output[i]);
        if ((i + 1) % 16 == 0) std::printf("\n");
    }

    VTAMemFree(region);
    VTADeviceFree(dev);
    return 0;
}



/*

./build_run_sim.sh



~/vta-mlir/build/bin/vta-translate ~/Desktop/test.mlir --vta-binary -o ~/Desktop/out.bin
~/vta-mlir/run_sim ~/Desktop/out.bin ~/Desktop/test.data

*/