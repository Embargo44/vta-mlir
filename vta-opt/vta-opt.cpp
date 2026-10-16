//MLIR opt tool for the VTA dialect.

// Standard MLIR infrastructure.
#include "mlir/Dialect/Arithmetic/IR/Arithmetic.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/InitAllDialects.h"
#include "mlir/InitAllPasses.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Support/FileUtilities.h"
#include "mlir/Tools/mlir-opt/MlirOptMain.h"

// Standard LLVM infrastructure..
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/InitLLVM.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/ToolOutputFile.h"

// Generated from VTAOps.td.
#include "VTA/VTADialect.h"

// Written in this project.
#include "VTA/Passes.h"



int main(int argc, char **argv) {
  //Registers all MLIR standard passes so --help lists them.
  mlir::registerAllPasses();

  //Registers pass. Lambda calls the factory in lib/VTA/Passes.cpp.
  mlir::registerPass([]() -> std::unique_ptr<mlir::Pass> {
      return mlir::vta::createCheckStructurePass();   });
  mlir::registerPass([]() -> std::unique_ptr<mlir::Pass> {
      return mlir::vta::createCheckUcodePass(); }); 


  mlir::registerPass([]() -> std::unique_ptr<mlir::Pass> {
      return mlir::vta::createTransformUcodeToLoadOpPass();  });
  mlir::registerPass([]() -> std::unique_ptr<mlir::Pass> {
      return mlir::vta::createTransformNoOpsPass(); }); 


  mlir::registerPass([]() -> std::unique_ptr<mlir::Pass> { 
      return mlir::vta::createCheckDependancyPass();  });  

      
  mlir::registerPass([]() -> std::unique_ptr<mlir::Pass> {
      return mlir::vta::createTransformGeneralStructurePass();  }); 


  


  
    
    
        

  

  
  mlir::DialectRegistry registry;
  registry.insert<mlir::vta::VTADialect, mlir::arith::ArithmeticDialect, mlir::func::FuncDialect>();
  
 
  return mlir::asMainReturnCode(mlir::MlirOptMain(argc, argv, "VTA optimizer driver\n", registry));
}