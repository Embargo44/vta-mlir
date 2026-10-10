

#ifndef VTA_PASSES_H
#define VTA_PASSES_H

//Standard C++.
#include <memory>

namespace mlir {
class Pass;
namespace vta {

//Factory for the pass declared in include/VTA/VTAOps.td
//Defined in lib/VTA/Passes.cpp. Called from:
//  - vta-opt/vta-opt.cpp (via mlir::registerPass)
//  - vta-translate/vta-translate.cpp (via pm.addPass before translation)
std::unique_ptr<::mlir::Pass> createCheckStructurePass();
std::unique_ptr<::mlir::Pass> createTransformUcodeToLoadOpPass();
std::unique_ptr<::mlir::Pass> createTransformGeneralStructurePass();
std::unique_ptr<::mlir::Pass> createCheckDependancyPass();
std::unique_ptr<::mlir::Pass> createTransformNoOpsPass();

} // namespace vta
} // namespace mlir

#endif // VTA_PASSES_H