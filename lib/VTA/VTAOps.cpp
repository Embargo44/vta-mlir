//======================================================================================================================// 
//Gets attached to the VTAOps.cpp file from TableGen. 
//Includes Misc stuff                                                                                             
//======================================================================================================================//



//custom description file for hardware
#include "VTA/CustomHardwareDescription.h"

// Standard MLIR infrastructure.
#include "mlir/Support/LogicalResult.h"
#include "mlir/IR/OpImplementation.h"

// Generated from VTAOps.td
#include "VTA/VTAOps.h"
#include "VTA/VTADialect.h"

//Namespace shortcuts 
using namespace mlir;
using namespace mlir::vta;


//Pulls in builders, getters, and verify() stubs for every op in VTAOps.td
#define GET_OP_CLASSES

//Needed for the interfaces
#include "VTA/VTAInterfaces.cpp.inc"
#include "VTA/VTAOps.cpp.inc"



// Memory type parser and printer for custom<MemoryType> in .td
//Turns keyword into ints, acceptable for the op def. (syntax sugar)
// (qst) - doing this step by step



#include "VTAOpsVerifiers.inc"    //verifier attached here (qst)