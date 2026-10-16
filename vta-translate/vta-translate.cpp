//custom description file for hardware
#include "VTA/CustomHardwareDescription.h"

// Standard MLIR infrastructure.
#include "mlir/Dialect/Func/IR/FuncOps.h"               
#include "mlir/Tools/mlir-translate/MlirTranslateMain.h" 
#include "mlir/IR/BuiltinOps.h"                          
#include "mlir/IR/DialectRegistry.h"                     
#include "mlir/Support/LogicalResult.h"                  
#include "mlir/Tools/mlir-translate/Translation.h"       
#include "llvm/Support/raw_ostream.h"                    

// Standard C++
#include <vector>                                        
#include <cstring>

// Generated from VTAOps.td
#include "VTA/VTADialect.h"                              
#include "VTA/VTAOps.h"                                  
                             

// Pass infrastructure
#include "mlir/Pass/Pass.h"                              
#include "VTA/Passes.h"                                  
#include "mlir/Pass/PassManager.h"                      

using namespace mlir;





//Entry point called by mlir-translate with --vta-binary.
static LogicalResult translateVTAtoBit(Operation *op, llvm::raw_ostream &output) {
    auto module = dyn_cast<ModuleOp>(op);
    if (!module)
        return failure();



//====================================================================================================================
    //Pass pipeline. Order matters 
    mlir::PassManager pm(module.getContext());

    //pm.addPass(vta::createTransformGeneralStructurePass());
    pm.addPass(vta::createTransformNoOpsPass());

    pm.addPass(vta::createTransformUcodeToLoadOpPass()); 
    pm.addPass(vta::createCheckStructurePass());
    //pm.addPass(vta::createCheckUcodePass());   
    
    pm.addPass(vta::createCheckDependancyPass());
        if (mlir::failed(pm.run(module)))
            return failure();


    //output buffers. insn_bytes->instruction region,
    //ucode_bytes -> uop record region. Both get written into the binary after the 4-byte length header.
    std::vector<uint8_t> insn_bytes;       
    std::vector<uint8_t> ucode_bytes;  

    
    
    //Walk every VTA op and pack it into its 16-byte (or 4-byte for uop)
    //binary form. The struct layouts come from CustomHardwareDescription.h
    //and must match the simulator's view of the same bytes.
    module.walk([&](Operation *innerOp) {
        if (auto loadOp = dyn_cast<vta::LoadOp>(innerOp)) {
            VTAMemInsn insn = {};    
            insn.opcode         = VTA_OP_LOAD;
            insn.pop_prev_dep   = loadOp.getPopPrevDep();
            insn.pop_next_dep   = loadOp.getPopNextDep();
            insn.push_prev_dep  = loadOp.getPushPrevDep();
            insn.push_next_dep  = loadOp.getPushNextDep();
            insn.memory_type    = loadOp.getMemoryType();
            insn.sram_base      = loadOp.getSramBase();
            insn.dram_base      = loadOp.getDramBase();
            insn.y_size         = loadOp.getYSize();
            insn.x_size         = loadOp.getXSize();
            insn.x_stride       = loadOp.getXStride();
            insn.y_pad_0        = loadOp.getYPad0();
            insn.y_pad_1        = loadOp.getYPad1();
            insn.x_pad_0        = loadOp.getXPad0();
            insn.x_pad_1        = loadOp.getXPad1();

            //memcpy into a byte buffer. The 16-byte size is fixed in hardware
            char buf[16] = {};
            std::memcpy(buf, &insn, sizeof(VTAMemInsn));
            insn_bytes.insert(insn_bytes.end(), buf, buf + 16);
        }
        else if (auto storeOp = dyn_cast<vta::StoreOp>(innerOp)) {
            VTAMemInsn insn = {};
            insn.opcode         = VTA_OP_STORE;
            insn.pop_prev_dep   = storeOp.getPopPrevDep();
            insn.pop_next_dep   = storeOp.getPopNextDep();
            insn.push_prev_dep  = storeOp.getPushPrevDep();
            insn.push_next_dep  = storeOp.getPushNextDep();
            insn.memory_type    = storeOp.getMemoryType();
            insn.sram_base      = storeOp.getSramBase();
            insn.dram_base      = storeOp.getDramBase();
            insn.y_size         = storeOp.getYSize();
            insn.x_size         = storeOp.getXSize();
            insn.x_stride       = storeOp.getXStride();
            insn.y_pad_0        = storeOp.getYPad0();
            insn.y_pad_1        = storeOp.getYPad1();
            insn.x_pad_0        = storeOp.getXPad0();
            insn.x_pad_1        = storeOp.getXPad1();

            char buf[16] = {};
            std::memcpy(buf, &insn, sizeof(VTAMemInsn));
            insn_bytes.insert(insn_bytes.end(), buf, buf + 16);
        }
        else if (auto gemmOp = dyn_cast<vta::GemmOp>(innerOp)) {
            VTAGemInsn insn = {};
            insn.opcode         = VTA_OP_GEMM;
            insn.pop_prev_dep   = gemmOp.getPopPrevDep();
            insn.pop_next_dep   = gemmOp.getPopNextDep();
            insn.push_prev_dep  = gemmOp.getPushPrevDep();
            insn.push_next_dep  = gemmOp.getPushNextDep();
            insn.reset_reg      = gemmOp.getResetReg();
            insn.uop_bgn        = gemmOp.getUopBgn();
            insn.uop_end        = gemmOp.getUopEnd();
            insn.iter_out       = gemmOp.getIterOut();
            insn.iter_in        = gemmOp.getIterIn();
            insn.dst_factor_out = gemmOp.getDstFactorOut();
            insn.dst_factor_in  = gemmOp.getDstFactorIn();
            insn.src_factor_out = gemmOp.getSrcFactorOut();
            insn.src_factor_in  = gemmOp.getSrcFactorIn();
            insn.wgt_factor_out = gemmOp.getWgtFactorOut();
            insn.wgt_factor_in  = gemmOp.getWgtFactorIn();

            char buf[16] = {};
            std::memcpy(buf, &insn, sizeof(VTAGemInsn));
            insn_bytes.insert(insn_bytes.end(), buf, buf + 16);
        }
        else if (auto aluOp = dyn_cast<vta::AluOp>(innerOp)) {
            VTAAluInsn insn = {};
            insn.opcode         = VTA_OP_ALU;
            insn.pop_prev_dep   = aluOp.getPopPrevDep();
            insn.pop_next_dep   = aluOp.getPopNextDep();
            insn.push_prev_dep  = aluOp.getPushPrevDep();
            insn.push_next_dep  = aluOp.getPushNextDep();
            insn.reset_reg      = aluOp.getResetReg();
            insn.uop_bgn        = aluOp.getUopBgn();
            insn.uop_end        = aluOp.getUopEnd();
            insn.iter_out       = aluOp.getIterOut();
            insn.iter_in        = aluOp.getIterIn();
            insn.dst_factor_out = aluOp.getDstFactorOut();
            insn.dst_factor_in  = aluOp.getDstFactorIn();
            insn.src_factor_out = aluOp.getSrcFactorOut();
            insn.src_factor_in  = aluOp.getSrcFactorIn();
            insn.alu_opcode     = aluOp.getAluOpcode();
            insn.use_imm        = aluOp.getUseImm();
            insn.imm            = aluOp.getImm();

            char buf[16] = {};
            std::memcpy(buf, &insn, sizeof(VTAAluInsn));
            insn_bytes.insert(insn_bytes.end(), buf, buf + 16);
        }
        else if (auto finishOp = dyn_cast<vta::FinishOp>(innerOp)) {
            //finish has no body
            VTAGenericInsn insn = {};
            insn.opcode = VTA_OP_FINISH;
            char buf[16] = {};
            std::memcpy(buf, &insn, sizeof(VTAGenericInsn));
            insn_bytes.insert(insn_bytes.end(), buf, buf + 16);
        }
        else if (auto ucodeOp = dyn_cast<vta::UcodeOp>(innerOp)) {
            //Ucode gets cast differently
           for (Attribute a : ucodeOp.getRecords().getValue()) {
                auto triple = a.cast<ArrayAttr>();
                VTAUop uop = {};
                uop.dst_idx = triple[0].cast<IntegerAttr>().getInt();
                uop.src_idx = triple[1].cast<IntegerAttr>().getInt();
                uop.wgt_idx = triple[2].cast<IntegerAttr>().getInt();
                char buf[4] = {};
                std::memcpy(buf, &uop, sizeof(VTAUop));
                ucode_bytes.insert(ucode_bytes.end(), buf, buf + 4);
            }
        }

    });

    //===------------------------------------------------------------------===//
    // Verifier for Translate
    //===------------------------------------------------------------------===//

    //ucode load x_size matches ucode record count.
    uint32_t expected_ucode_records =
        (uint32_t)(ucode_bytes.size() / VTA_UCODE_RECORD_BYTES);

    uint32_t found_ucode_x_size = 0;
    for (size_t i = 0; i + VTA_INSN_BYTES <= insn_bytes.size(); i += VTA_INSN_BYTES) {
        VTAMemInsn *m = (VTAMemInsn *)(insn_bytes.data() + i);
        if (m->opcode == VTA_OP_LOAD && m->memory_type == VTA_MEM_UOP) {
            found_ucode_x_size = m->x_size;
            break;
        }
    }
    if (found_ucode_x_size != expected_ucode_records) {
        module.emitError("ucode load x_size does not match ucode record count");
        return failure();
    }

    
    //insn_len fits in the 4-byte header field.
    if (insn_bytes.size() > UINT32_MAX) {
        module.emitError("instruction bytes exceed 32-bit header field");
        return failure();
    }

    //Output format: [4-byte LE insn_len][insn_bytes][ucode_bytes].
    //run_sim.cpp splits the file on insn_len.
    uint32_t insn_len = (uint32_t)insn_bytes.size();
    char hdr[4];
    std::memcpy(hdr, &insn_len, 4);
    output.write(hdr, 4);

    output.write((const char *)insn_bytes.data(), insn_bytes.size());

    output.write((const char *)ucode_bytes.data(), ucode_bytes.size());

    return success();
}

//Registers the translation under the name "vta-binary", so the CLI
//flag is --vta-binary. Claims VTADialect and func.
static void registerVTATranslate() {
    TranslateFromMLIRRegistration registration("vta-binary",translateVTAtoBit,[](DialectRegistry &registry) {registry.insert<vta::VTADialect,mlir::func::FuncDialect>();});
}


//Standard mlir-translate entry. Passes argv straight through.
int main(int argc, char **argv) {
    //mlir::registerAllTranslations();
    registerVTATranslate();
    return failed(mlir::mlirTranslateMain(argc, argv, "VTA Translation Tool"));
}




// cd ~/vta-mlir/build
//./bin/vta-translate ~/Desktop/test.mlir --vta-binary -o ~/Desktop/result.txt

/*

cd ~/vta-mlir
rm -rf build
mkdir build
cd build
cmake ..
make 

*/