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

//Order is Important. These have to be forward declared (and have to be before the using)
static ParseResult parseMemoryType(OpAsmParser &p, IntegerAttr &attr);
static void printMemoryType(OpAsmPrinter &p, Operation *op, IntegerAttr attr);

//Pulls in builders, getters, and verify() stubs for every op in VTAOps.td
#define GET_OP_CLASSES
#include "VTA/VTAOps.cpp.inc"



// Memory type parser and printer for custom<MemoryType> in .td
//Turns keyword into ints, acceptable for the op def. (syntax sugar)
// (qst) - doing this step by step

static ParseResult parseMemoryType(OpAsmParser &p, IntegerAttr &attr) {
    int v;
    
    if (p.parseOptionalInteger(v).hasValue()) {
        attr = IntegerAttr::get(IntegerType::get(p.getContext(), 8), v);
        return success();
    }
    //Keywordw: mem UOP, mem INP -> nums
    StringRef s;
    if (p.parseKeyword(&s))
        return failure();
    if      (s == "UOP") v = 0;
    else if (s == "WGT") v = 1;
    else if (s == "INP") v = 2;
    else if (s == "ACC") v = 3;
    else if (s == "OUT") v = 4;
    else
        return p.emitError(p.getCurrentLocation(), "unknown memory type '" + s + "'");
    attr = IntegerAttr::get(IntegerType::get(p.getContext(), 8), v);
    return success();
}

//Inverse of parseMemoryType. Turns the stored integer back into a keyword
static void printMemoryType(OpAsmPrinter &p, Operation *op, IntegerAttr attr) {
    switch (attr.getInt()) {
        case 0: p << "UOP"; break;
        case 1: p << "WGT"; break;
        case 2: p << "INP"; break;
        case 3: p << "ACC"; break;
        case 4: p << "OUT"; break;
        default: p << attr.getInt(); break;
    }
}




#include "VTAOpsVerifiers.inc"    //verifier attached here (qst)